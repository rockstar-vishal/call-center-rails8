class TimeIntervals
  INTERVALS = [
    {
      name: '8am_10am',
      label: '8am - 10am',
      start_hour: 8,
      end_hour: 10,
      color: 'blue',
      color_class: 'bg-blue-100 text-blue-800',
      total_color_class: 'bg-blue-200 text-blue-900'
    },
    {
      name: '10am_12pm',
      label: '10am - 12pm',
      start_hour: 10,
      end_hour: 12,
      color: 'green',
      color_class: 'bg-green-100 text-green-800',
      total_color_class: 'bg-green-200 text-green-900'
    },
    {
      name: '12pm_2pm',
      label: '12pm - 2pm',
      start_hour: 12,
      end_hour: 14,
      color: 'emerald',
      color_class: 'bg-emerald-100 text-emerald-800',
      total_color_class: 'bg-emerald-200 text-emerald-900'
    },
    {
      name: '2pm_4pm',
      label: '2pm - 4pm',
      start_hour: 14,
      end_hour: 16,
      color: 'yellow',
      color_class: 'bg-yellow-100 text-yellow-800',
      total_color_class: 'bg-yellow-200 text-yellow-900'
    },
    {
      name: '4pm_6pm',
      label: '4pm - 6pm',
      start_hour: 16,
      end_hour: 18,
      color: 'orange',
      color_class: 'bg-orange-100 text-orange-800',
      total_color_class: 'bg-orange-200 text-orange-900'
    },
    {
      name: '6pm_8pm',
      label: '6pm - 8pm',
      start_hour: 18,
      end_hour: 20,
      color: 'purple',
      color_class: 'bg-purple-100 text-purple-800',
      total_color_class: 'bg-purple-200 text-purple-900'
    },
    {
      name: '8pm_10pm',
      label: '8pm - 10pm',
      start_hour: 20,
      end_hour: 22,
      color: 'red',
      color_class: 'bg-red-100 text-red-800',
      total_color_class: 'bg-red-200 text-red-900'
    },
    {
      name: 'others',
      label: 'Others',
      start_hour: nil,
      end_hour: nil,
      color: 'gray',
      color_class: 'bg-gray-100 text-gray-800',
      total_color_class: 'bg-gray-200 text-gray-900'
    }
  ].freeze

  def self.all
    INTERVALS
  end

  def self.find(name)
    INTERVALS.find { |interval| interval[:name] == name }
  end

  def self.names
    INTERVALS.map { |interval| interval[:name] }
  end

  def self.business_hours_intervals
    INTERVALS.reject { |interval| interval[:name] == 'others' }
  end

  def self.others_interval
    find('others')
  end
end
