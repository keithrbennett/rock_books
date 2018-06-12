require 'date'

module RockBooks
module JournalEntryFilters

  module_function


  def filter(entries, entry_filter)
    entries.select { |entry| entry_filter.(entry) }
  end


  # Dates can be provided as a Ruby Date object, or as a string that will be converted to date (yyyy-mm-dd).
  def to_date(string_or_date_object)
    if string_or_date_object.is_a?(String)
      Date.iso8601(string_or_date_object)
    else
      string_or_date_object
    end
  end


  def null_filter
    ->(entry) { true }
  end


  def year(target_year)
    ->(entry) { entry.date.year == target_year }
  end


  def month(target_year, target_month)
    ->(entry) do
      entry.date.year == target_year && entry.date.month == target_month
    end
  end


  def day(target_year, target_month, target_day)
    ->(entry) do
      entry.date.year == target_year && entry.date.month == target_month && entry.date.day == target_day
    end
  end


  def account_code(account_code)
    ->(entry) do
      entry.acct_amounts.map(&:code).detect { |code| code == account_code }
    end
  end


  def date_on_or_after(date)
    ->(entry) { entry.date >= to_date(date) }

  end


  def date_on_or_before(date)
    date = to_date(date)
    ->(entry) { entry.date <= date }
  end


  def date_in_range(start_date, end_date)
    start_date = to_date(start_date)
    end_date = to_date(end_date)
    ->(entry) { entry.date >= start_date && entry.date <= end_date }
  end


  def all(*filters)
    ->(entry) { filters.all? { |filter| filter.(entry) } }
  end


  def any(*filters)
    ->(entry) { filters.any? { |filter| filter.(entry) } }
  end


  def none(*filters)
    ->(entry) { filters.none? { |filter| filter.(entry) } }
  end
end
end

