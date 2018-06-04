require_relative '../types/acct_amount'
require_relative '../filters/acct_amount_filters'

module RockBooks

class JournalEntry < Struct.new(:date, :acct_amounts, :doc_short_name, :description, :receipts)


  def initialize(date, acct_amounts = [], doc_short_name = nil, description = '', receipts = [])
    super
  end


  def self.entries_acct_amounts(entries)
    acct_amounts = entries.each_with_object([]) do |entry, acct_amounts|
      acct_amounts << entry.acct_amounts
    end
    acct_amounts.flatten!
    acct_amounts
  end


  def self.entries_containing_account_code(entries, account_code)
    entries.select { |entry| entry.contains_account?(account_code) }
  end


  def self.total_for_code(entries, account_code)
    entries.map { |entry| entry.total_for_code(account_code)}.sum
  end


  def self.sort_entries_by_amount_descending!(entries)
    entries.sort_by! do |entry|
      [entry.total_absolute_value, entry.doc_short_name]
      end
    entries.reverse!
  end


  def total_for_code(account_code)
    acct_amounts_with_code(account_code).map(&:amount).sum
  end


  def acct_amounts_with_code(account_code)
    AcctAmount.filter(acct_amounts, AcctAmountFilters.account_code(account_code))
  end


  def total_amount
    acct_amounts.inject(0) { |sum, aa| sum + aa.amount }
  end


  # Gets the absolute value of the positive (or negative) amounts in this entry.
  # This is used to sort by transaction amount, since total of all amounts will always be zero.
  def total_absolute_value
    acct_amounts.map(&:amount).select { |n| n.positive? }.sum
  end


  def balanced?
    total_amount == 0.0
  end


  def contains_account?(account_code)
    acct_amounts.any? { |acct_amount| acct_amount.code == account_code }
  end
end

end
