require 'date'
require 'json'
require 'yaml'

require_relative '../errors/account_not_found_error'
require_relative '../types/acct_amount'
require_relative '../types/journal_entry_context'
require_relative 'journal_entry'
require_relative 'journal_entry_builder'
require_relative '../reports/reporter'

module RockBooks

# The journal will create journal entries, each of which containing an array of account/amount objects,
# copying the entry date to them.
#
# Warning: Any line beginning with a number will be assumed to be the date of a data line for an entry,
# so descriptions cannot begin with a number.
class Journal

  def self.from_file(chart_of_accounts, file)
    self.new(chart_of_accounts, File.readlines(file).map(&:chomp))
  end


  def self.from_string(chart_of_accounts, string)
    self.new(chart_of_accounts, string.split("\n"))
  end


  # Returns the entries in the specified documents, sorted by date and document short name,
  # optionally filtered with the specified filter.
  def self.entries_in_documents(documents, filter = nil)
    entries = documents.each_with_object([]) do |document, entries|
      entries << document.entries
    end.flatten

    if filter
      entries = entries.select {|entry| filter.(entry) }
    end

    entries.sort_by do |entry|
      [entry.date, entry.doc_short_name]
    end
  end




    def self.acct_amounts_in_documents(documents, entries_filter = nil, acct_amounts_filter = nil)
    entries = entries_in_documents(documents, entries_filter)

    acct_amounts = entries.each_with_object([]) do |entry, acct_amounts|
      acct_amounts << entry.acct_amounts
    end.flatten

    if acct_amounts_filter
      acct_amounts = AcctAmount.filter(acct_amounts, filter)
    end

    acct_amounts
  end


  class Entry < Struct.new(:date, :amount, :acct_amounts, :description); end

  attr_reader :short_name, :account_code, :chart_of_accounts, :date_prefix, :debit_or_credit, :doc_type, :title, :entries

  # short_name is a name that will appear on reports identifying the journal from which a transaction comes
  def initialize(chart_of_accounts, input_lines, short_name = nil)
    @chart_of_accounts = chart_of_accounts
    @short_name = short_name
    @entries = []
    @date_prefix = ''
    @title = ''
    input_lines.each_with_index do |line, linenum|
      context = JournalEntryContext.new(self, linenum + 1, line)
      parse_line(context)
    end
  end


  def parse_line(journal_entry_context)
    line = journal_entry_context.line
    case line.strip
    when /^@doc_type:/
      @doc_type = line.split(/^@doc_type:/).last.strip
    when  /^@account_code:/
      @account_code = line.split(/^@account_code:/).last.strip

      unless chart_of_accounts.include?(@account_code)
        raise AccountNotFoundError.new(@account_code, journal_entry_context)
      end

      # if debit or credit has not yet been specified, inherit the setting from the account:
      unless @debit_or_credit
        @debit_or_credit = chart_of_accounts.debit_or_credit_for_code(@account_code)
      end

    when /^@title:/
      @title = line.split(/^@title:/).last.strip
    when /^@short_name:/
      @short_name = line.split(/^@short_name:/).last.strip
    when /^@date_prefix:/
      @date_prefix = line.split(/^@date_prefix:/).last.strip
    when /^@debit_or_credit:/
      data = line.split(/^@debit_or_credit:/).last.strip
      @debit_or_credit = data.to_sym
    when /^$/
      # ignore empty line
    when /^#/
      # ignore comment line
    when /^\d/  # a date/acct/amount line starting with a number
      entries << JournalEntryBuilder.new(journal_entry_context).build
    else # Text line(s) to be attached to the most recently parsed transaction
      unless entries.last
        raise Error.new("Entry for this description cannot be found: #{line}")
      end
      entries.last.description << line << "\n"

      if /^Receipt:/.match(line)
        receipt_spec = line.split(/^Receipt:/).last.strip
        entries.last.receipts << receipt_spec
      end
    end
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


  def ==(other)
    # excluding date_prefix from this test intentionally because it does not
    # affect the parsed data.
    short_name        == other.short_name          && \
    account_code      == other.account_code        && \
    chart_of_accounts == other.chart_of_accounts   && \
    debit_or_credit   == other.debit_or_credit     && \
    doc_type          == other.doc_type            && \
    title             == other.title               && \
    entries           == other.entries
  end
end
end
