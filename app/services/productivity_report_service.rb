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
      user_data = {}
      TimeIntervals.all.each do |interval|
        column_name = "count_#{interval[:name]}"
        user_data[interval[:name]] = result.send(column_name).to_i
      end
      productivity_data[result.user_id] = user_data
    end

    productivity_data
  end

  def calculate_totals
    totals = {}
    TimeIntervals.all.each do |interval|
      totals[interval[:name]] = 0
    end

    productivity_data = calculate_productivity_data
    productivity_data.each_value do |user_data|
      user_data.each do |interval_name, count|
        totals[interval_name] += count
      end
    end

    totals
  end

  def time_interval_select_clause
    timezone_conversion = TimeRangeFilterService.timezone_conversion_string('leads_call_logs')
    
    select_clauses = TimeIntervals.all.map do |interval|
      if interval[:name] == 'others'
        "SUM(CASE WHEN EXTRACT(hour FROM #{timezone_conversion}) < 8 OR EXTRACT(hour FROM #{timezone_conversion}) >= 22 THEN 1 ELSE 0 END) as count_#{interval[:name]}"
      else
        "SUM(CASE WHEN EXTRACT(hour FROM #{timezone_conversion}) >= #{interval[:start_hour]} AND EXTRACT(hour FROM #{timezone_conversion}) < #{interval[:end_hour]} THEN 1 ELSE 0 END) as count_#{interval[:name]}"
      end
    end
    
    select_clauses.join(",\n      ")
  end
end
