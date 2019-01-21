require_relative '../errors/incorrect_sequence_error'
require_relative '../errors/transaction_not_balanced_error'
require_relative '../types/acct_amount'
require_relative '../types/journal_entry_context'
require_relative 'chart_of_accounts'
require_relative 'journal'

module RockBooks
class JournalEntryBuilder < Struct.new(:journal_entry_context)

  def journal;           journal_entry_context.journal;            end
  def linenum;           journal_entry_context.linenum;            end
  def line;              journal_entry_context.line;               end
  def chart_of_accounts; journal_entry_context.chart_of_accounts;  end


  def acct_amounts_from_tokens(tokens, date)
    acct_amounts = []

    tokens[0..-1].each_slice(2).each do |(account_code, amount)|
      acct_amounts <<  AcctAmount.create_with_chart_validation(date, account_code, amount, journal_entry_context)
    end

    acct_amounts
  end


  def validate_acct_amount_token_array_size(tokens)
    if tokens.size.odd?
      raise IncorrectSequenceError.new(tokens, journal_entry_context)
    end
  end


  def convert_amounts_to_floats(tokens)
    (1...tokens.size).step(2) do |amount_index|
      tokens[amount_index] = Float(tokens[amount_index])
    end
  end


  def general_journal?
    journal.doc_type == 'general_journal'
  end


  # For regular journal only, not general journal.
  # This converts the entered signs to the correct debit/credit signs.
  def convert_signs_for_debit_credit(tokens)

    # Adjust the sign of the amount for the main journal account (e.g. the checking account or credit card account)
    # e.g. If it's a checking account, it is an asset, a debit account, and the transaction total
    # will represent a credit to that checking account.
    adjust_sign_for_main_account = ->(amount) do
      (journal.debit_or_credit == :debit) ? -amount : amount
    end

    adjust_sign_for_other_accounts = ->(amount) do
      - adjust_sign_for_main_account.(amount)
    end

    tokens[1] = adjust_sign_for_main_account.(tokens[1])
    (3...tokens.size).step(2) do |amount_index|
      tokens[amount_index] = adjust_sign_for_other_accounts.(tokens[amount_index])
    end
  end


  # Returns an array of AcctAmount instances for the array of tokens.
  #
  # The following applies only to regular (not general) journals:
  #
  # this token array will start with the transaction's total amount
  # and be followed by account/amount pairs.
  #
  # Examples, assuming a line:
  # 2018-05-20  5.79  701  1.23  702  4.56
  #
  # and the journal account is '101', 'D' 'My Checking Account',
  # the following AcctAmoutns will be created:
  # [AcctAmount code: '101', amount: -5.79, AcctAmount code: '701', 1.23, AcctAmount code: '702', 4.56, ]
  #
  # shortcut: if there is only 1 account (that is, it is not a split entry), give it the total amount
  # ['5.79', '701'] --> [AcctAmount code: '101', amount: -5.79, AcctAmount code: '701', 5.79]
  #
  # If the account is a credit account, the signs will be reversed.
  def build_acct_amount_array(date, tokens)

    unless general_journal?
      if journal.account_code.nil?
        raise Error.new("An '@account_code: ' line has not yet been specified in this journal." )
      end

      # Prepend the array with the document account code so that total amount will be associated with it.
      tokens.unshift(journal.account_code)

      # For convenience in regular journals, when there is no split,
      # we permit the user to omit the amount after the
      # account code, since we know it will be equal to the total amount.
      # We add it here, because we *will* need to include it in the data.
      if tokens.size == 3
        tokens << tokens[1]  # copy the total amount to the sole account's amount
      end
    end

    validate_acct_amount_token_array_size(tokens)

    # Tokens in the odd numbered positions are dollar amounts that need to be converted from string to float.
    begin
      convert_amounts_to_floats(tokens)
    rescue ArgumentError
      raise Error.new("Float conversion or other parse error for #{date}, #{tokens}.")
    end

    unless general_journal?
      # As a convenience, all normal journal amounts are entered as positive numbers.
      # This code negates the amounts as necessary so that debits are + and credits are -.
      # In general journals, the debit and credit amounts must be entered correctly already.
      convert_signs_for_debit_credit(tokens)
    end

    acct_amounts_from_tokens(tokens, date)
  end


  def validate_transaction_is_balanced(acct_amounts)
    sum = acct_amounts.map(&:amount).sum.round(4)
    unless sum == 0.0
      raise TransactionNotBalancedError.new(sum, journal_entry_context)
    end
  end


  def build
    # this is an account line in the form: yyyy-mm-dd 101 blah blah blah
    tokens = line.split
    acct_amount_tokens = tokens[1..-1]
    date_string = journal.date_prefix + tokens[0]

    raise_date_format_error = -> do
      raise Error.new("Date string was '#{date_string}' but should be a valid date in the form YYYY-MM-DD in " + \
          "journal '#{journal_entry_context[:journal].title}', line #{journal_entry_context[:linenum]}.")
    end

    raise_date_format_error.() if date_string.length != 10

    begin
      date = Date.iso8601(date_string)
    rescue ArgumentError
      raise_date_format_error.()
    end

    unless chart_of_accounts.included_in_period?(date)
      raise DateRangeError.new(date, chart_of_accounts.start_date,
          chart_of_accounts.end_date, journal_entry_context)
    end

    acct_amounts = build_acct_amount_array(date, acct_amount_tokens)
    validate_transaction_is_balanced(acct_amounts)
    JournalEntry.new(date, acct_amounts, journal.short_name)
  end
end
end