require 'date'
require 'json'
require 'yaml'

require_relative 'account_not_found_error'
require_relative 'acct_amount'
require_relative 'journal_common'
require_relative 'journal_entry'
require_relative 'reporter'

module RockBooks

# The journal will create journal entries, each of which containing an array of account/amount objects,
# copying the entry date to them.
#
# Warning: Any line beginning with a number will be assumed to be the date of a data line for an entry,
# so descriptions cannot begin with a number.
class Journal

  include JournalCommon

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




  # Parses main line of the entry, the one that includes the date, account number and amount entries
  def parse_main_transaction_line(line)
    if account_code.nil?
      raise Error.new("An '@account_code: ' line has not yet been specified in this journal." )
    end
    # this is an account line in the form: yyyy-mm-dd 101 blah blah blah
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
  # [AcctAmount code: '101', amount: -5.79, AcctAmount code: '701', 1.23, AcctAmount code: '702', 4.56, ]
  #
  # shortcut: if there is only 1 account (that is, it is not a split entry), give it the total amount
  # ['5.79', '701'] --> [AcctAmount code: '101', amount: -5.79, AcctAmount code: '701', 5.79]
  #
  # If the account is a credit account, the signs will be reversed.
  def build_acct_amount_array(date, tokens, want_account_validation = true)

    tokens = tokens.clone

    # Prepend the array with the document account code so that total amount will be associated with it.
    tokens.unshift(account_code)

    # For convenience, when there is no split, we permit the user to omit the amount after the
    # account code, since we know it will be equal to the total amount.
    # We add it here, because we *will* need to include it in the data.
    if tokens.size == 3
      tokens << tokens[1]  # copy the total amount to the sole account's amount
    end

    if tokens.size.odd?
      raise Error.new("Incorrect sequence of account codes and amounts: #{tokens}")
    end

    # Tokens in the odd numbered positions are dollar amounts that need to be converted from string to float.

    # As a convenience, all normal journal amounts are entered as positive numbers.
    # This code negates the amounts as necessary so that debits are + and credits are -.
    convert_signs_for_debit_credit = ->(tokens) do

      # Adjust the sign of the amount for the main journal account (e.g. the checking account or credit card account)
      # e.g. If it's a checking account, it is an asset, a debit account, and the transaction total
      # will represent a credit to that checking account.
      adjust_sign_for_main_account = ->(amount) do
        (debit_or_credit == :debit) ? -amount : amount
      end

      adjust_sign_for_other_accounts = ->(amount) do
        - adjust_sign_for_main_account.(amount)
      end

      tokens[1] = adjust_sign_for_main_account.(tokens[1])
      (3...tokens.size).step(2) do |amount_index|
        tokens[amount_index] = adjust_sign_for_other_accounts.(tokens[amount_index])
      end
    end

    convert_alternate_amounts_to_floats(tokens)
    convert_signs_for_debit_credit.(tokens)
    acct_amounts_from_tokens(tokens, date, want_account_validation)
  end


  def acct_amounts
    entries.each_with_object([]) { |entry, acct_amounts|  acct_amounts << entry.acct_amounts }.flatten
  end


  def totals_by_account
    acct_amounts.each_with_object(Hash.new(0)) { |aa, totals| totals[aa.code] += aa.amount }
  end


  def total_amount
    AcctAmount.total_amount(acct_amounts)
  end


  def to_s
    super.to_s + ': ' + \
    {
        account_code: account_code,
        debit_or_credit: debit_or_credit,
        title: title
    }.to_s
  end
end
end
