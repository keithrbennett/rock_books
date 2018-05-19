require 'date'
require 'json'
require 'yaml'

require_relative 'acct_amount'
require_relative 'journal_entry'

module RockBooks

# The journal will create journal entries, each of which containing an array of account/amount objects,
# copying the entry date to them.
#
# Warning: Any line beginning with a number will be assumed to be the date of a data line for an entry,
# so descriptions cannot begin with a number.
class Journal

  class Entry < Struct.new(:date, :amount, :acct_amounts, :description); end

  attr_reader :account_code, :chart_of_accounts, :date_prefix, :debit_or_credit, :doc_type, :title, :entries

  def to_h
    {
        title:           title,
        account_code:    account_code,
        debit_or_credit: debit_or_credit,
        doc_type:        doc_type,
        date_prefix:     date_prefix,
        entries:         entries
    }
  end


  def to_json; to_h.to_json; end
  def to_yaml; to_h.to_yaml; end


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
      else # Text line(s) to be attached to the most recently parsed transaction
        entries.last.description ||= ''
        entries.last.description << line << "\n"
      end
  end


  # Parses main line of the entry, the one that includes the date, account number and amount entries
  def parse_main_transaction_line(line)
    if account_code.nil?
      raise Error.new("An '@account_code: ' line has not yet been specified in this journal." )
    end
    # this is an account line in the form: 101 blah blah blah
    tokens = line.split
    date = Date.iso8601(date_prefix + tokens[0])
    acct_entries = build_acct_amount_array(date, tokens[1..-1])
    entries << JournalEntry.new(date, acct_entries, nil)
  end


  # Returns an array of AcctAmount instances for the array of tokens.
  #
  # This token array will start with the transaction's total amount and be followed by
  # account/amount pairs.
  #
  # Examples, assuming journal account is '101', 'D' 'My Checking Account', total amt is 5.79:
  # ['5.79', '701', '1.23', '702', '4.56'] --> \
  # [AcctAmount id: '101', amount: -5.79, AcctAmount id: '701', 1.23, AcctAmount id: '702', 4.56, ]
  #
  # shortcut: if there is only 1 account (that is, it is not a split entry), give it the total amount
  # ['5.79', '701'] --> [AcctAmount id: '101', amount: -5.79, AcctAmount id: '701', 5.79]
  #
  # If the account is a credit account, the signs will be reversed.
  def build_acct_amount_array(date, tokens)

    tokens = tokens.clone
    tokens.unshift(account_code)  # So the total amount will be associated with the journal's account code.
    if tokens.size == 3
      tokens << tokens[1]  # copy the total amount to the sole account's amount
    end

    if tokens.size.odd?
      raise Error.new("Incorrect sequence of account codes and amounts: #{tokens}")
    end

    # Tokens in the odd numbered positions are dollar amounts that need to be converted from string to float.
    convert_amounts_to_floats = ->(tokens) do
      (1...tokens.size).step(2) do |amount_index|
        tokens[amount_index] = Float(tokens[amount_index])
      end
    end

    # As a convenience, all normal journal amounts are entered as positive numbers.
    # This code negates the amounts as necessary so that debits are + and credits are -.
    convert_signs_for_debit_credit = ->(tokens) do

      # Adjust the sign of the amount for the main journal account (e.g. the checking account or credit card account)
      adjust_sign_for_main_account = ->(amount) do
        (debit_or_credit == :debit) ? amount : -amount
      end

      adjust_sign_for_other_accounts = ->(amount) do
        (debit_or_credit == :credit) ? amount : -amount
      end

      tokens[1] = adjust_sign_for_main_account.(tokens[1])
      (3...tokens.size).step(2) do |amount_index|
        tokens[amount_index] = adjust_sign_for_other_accounts.(tokens[amount_index])
      end
    end

    convert_amounts_to_floats.(tokens)
    convert_signs_for_debit_credit.(tokens)

    acct_amounts = []

    tokens[0..-1].each_slice(2).each do |(account_code, amount)|
      acct_amounts << AcctAmount.new(date, account_code, amount)
    end

    acct_amounts
  end


  def acct_amounts
    entries.each_with_object([]) { |entry, acct_amounts|  acct_amounts << entry.acct_amounts }.flatten
  end


  def totals_by_account
    aas = acct_amounts
    totals = aas.each_with_object(Hash.new(0)) { |aa, totals| totals[aa.acct_id] += aa.amount }
    puts totals
    totals
  end

end
end
