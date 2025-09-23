class TimeRangeFilterService
  def initialize(logs, time_range)
    @logs = logs
    @time_range = time_range
  end

  def call
    return @logs if @time_range.blank?
    
    timezone_conversion = build_timezone_conversion
    interval = TimeIntervals.find(@time_range)
    
    return @logs unless interval
    
    if interval[:name] == 'others'
      @logs.where("EXTRACT(hour FROM #{timezone_conversion}) < 8 OR EXTRACT(hour FROM #{timezone_conversion}) >= 22")
    else
      @logs.where("EXTRACT(hour FROM #{timezone_conversion}) >= #{interval[:start_hour]} AND EXTRACT(hour FROM #{timezone_conversion}) < #{interval[:end_hour]}")
    end
  end

  # Class method to get timezone conversion string for use in other services
  def self.timezone_conversion_string(table_name = 'leads_call_logs')
    pg_timezone = self.postgresql_timezone
    "#{table_name}.created_at AT TIME ZONE 'UTC' AT TIME ZONE '#{pg_timezone}'"
  end

  private

  def build_timezone_conversion
    pg_timezone = postgresql_timezone
    "leads_call_logs.created_at AT TIME ZONE 'UTC' AT TIME ZONE '#{pg_timezone}'"
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

  # Class method version of postgresql_timezone
  def self.postgresql_timezone
    case Time.zone.name
    when 'Kolkata' then 'Asia/Kolkata'
    when 'New York' then 'America/New_York'
    when 'London' then 'Europe/London'
    when 'Tokyo' then 'Asia/Tokyo'
    else Time.zone.name
    end
  end
end
