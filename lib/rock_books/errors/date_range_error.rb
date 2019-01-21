module RockBooks
  class DateRangeError < RuntimeError

    attr_reader :date, :start_date, :end_date, :extra_string

    def initialize(date, start_date, end_date, extra_string = nil)
      @date = date
      @start_date = start_date
      @end_date = end_date
      @extra_string = extra_string
    end

    def to_s
      s = "#{date} is not within this data set's period of #{start_date} to #{end_date}"
      s << " (#{extra_string})" if extra_string
      s << '.'
      s
    end
  end
end