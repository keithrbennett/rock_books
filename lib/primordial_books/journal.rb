require 'date'

require_relative 'acct_amount'
require_relative 'journal_entry'

module PrimordialBooks

# The journal will create journal entries, each of which containing an array of account/amount objects,
# copying the entry date to them.
class Journal

  class Entry < Struct.new(:date, :amount, :acct_amounts, :description); end

  attr_reader :account_code, :chart_of_accounts, :date_prefix, :debit_or_credit, :doc_type, :title, :entries


  def initialize(chart_of_accounts, input_string)
    @chart_of_accounts = chart_of_accounts
    @entries = []
    @date_prefix = ''
    lines = input_string.split("\n")
    lines.each { |line| parse_line(line) }
  end




  def parse_line(line)
    case line.strip
      when /^@doc_type:/
        @doc_type = line.split('doc_type:').last.strip
      when  /^@account_code:/
        @account_code = line.split('account_code:').last.strip
        @debit_or_credit = chart_of_accounts.debit_or_credit_for_id(account_code)
        if @debit_or_credit.nil?
          raise Error.new("Account code #{@account_code} not found in Chart of Accounts.")
        end
      when /^@title:/
        @title = line.split('title:').last.strip
      when /^@date_prefix:/
        @date_prefix = line.split('@date_prefix:').last.strip
      when /^$/
        # ignore empty line
      when /^#/
        # ignore comment line
      when /^\d/  # a date/acct/amount line starting with a number
        parse_main_transaction_line(line)
      else # A text line to be attached to the most recently parsed transaction
        # ?
      end
  end


  # Parses main line of the entry, the one that includes the date, account number and amount entries
  def parse_main_transaction_line(line)
    # this is an account line in the form: 101 blah blah blah
    tokens = line.split
    date = Date.iso8601(date_prefix + tokens[0])
    total_amount = tokens[1].to_f
    acct_entries = AcctAmount.parse_tokens(date, tokens[2..-1], total_amount)
    entries << JournalEntry.new(date, acct_entries, nil)
  end

end
end
