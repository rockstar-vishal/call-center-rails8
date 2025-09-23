class ProductivityReportService
  def initialize(filtered_logs, users)
    @filtered_logs = filtered_logs
    @users = users
  end

  def call
    {
      productivity_data: calculate_productivity_data,
      totals: calculate_totals,
      result_count: @filtered_logs.count
    }
  end

  private

  def calculate_productivity_data
    productivity_results = @filtered_logs
      .select("leads_call_logs.user_id, #{time_interval_select_clause}")
      .group("leads_call_logs.user_id")

    productivity_data = {}
    productivity_results.each do |result|
      productivity_data[result.user_id] = {
        '8am_10am' => result.count_8am_10am.to_i,
        '10am_2pm' => result.count_10am_2pm.to_i,
        '2pm_4pm' => result.count_2pm_4pm.to_i,
        '4pm_6pm' => result.count_4pm_6pm.to_i,
        '6pm_8pm' => result.count_6pm_8pm.to_i,
        '8pm_10pm' => result.count_8pm_10pm.to_i,
        'others' => result.count_others.to_i
      }
    end

    productivity_data
  end

  def calculate_totals
    totals = {
      '8am_10am' => 0,
      '10am_2pm' => 0,
      '2pm_4pm' => 0,
      '4pm_6pm' => 0,
      '6pm_8pm' => 0,
      '8pm_10pm' => 0,
      'others' => 0
    }

    productivity_data = calculate_productivity_data
    productivity_data.each_value do |user_data|
      totals.each_key do |key|
        totals[key] += user_data[key]
      end
    end

    totals
  end

  def time_interval_select_clause
    pg_timezone = postgresql_timezone
    timezone_conversion = "leads_call_logs.created_at AT TIME ZONE 'UTC' AT TIME ZONE '#{pg_timezone}'"
    
    <<~SQL
      SUM(CASE WHEN EXTRACT(hour FROM #{timezone_conversion}) >= 8 AND EXTRACT(hour FROM #{timezone_conversion}) < 10 THEN 1 ELSE 0 END) as count_8am_10am,
      SUM(CASE WHEN EXTRACT(hour FROM #{timezone_conversion}) >= 10 AND EXTRACT(hour FROM #{timezone_conversion}) < 14 THEN 1 ELSE 0 END) as count_10am_2pm,
      SUM(CASE WHEN EXTRACT(hour FROM #{timezone_conversion}) >= 14 AND EXTRACT(hour FROM #{timezone_conversion}) < 16 THEN 1 ELSE 0 END) as count_2pm_4pm,
      SUM(CASE WHEN EXTRACT(hour FROM #{timezone_conversion}) >= 16 AND EXTRACT(hour FROM #{timezone_conversion}) < 18 THEN 1 ELSE 0 END) as count_4pm_6pm,
      SUM(CASE WHEN EXTRACT(hour FROM #{timezone_conversion}) >= 18 AND EXTRACT(hour FROM #{timezone_conversion}) < 20 THEN 1 ELSE 0 END) as count_6pm_8pm,
      SUM(CASE WHEN EXTRACT(hour FROM #{timezone_conversion}) >= 20 AND EXTRACT(hour FROM #{timezone_conversion}) < 22 THEN 1 ELSE 0 END) as count_8pm_10pm,
      SUM(CASE WHEN EXTRACT(hour FROM #{timezone_conversion}) < 8 OR EXTRACT(hour FROM #{timezone_conversion}) >= 22 THEN 1 ELSE 0 END) as count_others
    SQL
  end

  def postgresql_timezone
    case Time.zone.name
    when 'Kolkata' then 'Asia/Kolkata'
    when 'New York' then 'America/New_York'
    when 'London' then 'Europe/London'
    when 'Tokyo' then 'Asia/Tokyo'
    else Time.zone.name
    end
  end
end
