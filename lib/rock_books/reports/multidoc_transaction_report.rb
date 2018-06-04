require_relative '../documents/journal'
require_relative 'reporter'
require_relative 'report_context'

module RockBooks

class MultidocTransactionReport

  include Reporter

  attr_accessor :context

  SORT_BY_VALID_OPTIONS = %i(date_and_account  amount)

  def initialize(report_context)
    @context = report_context
  end


  def generate_header(sort_by)
    lines = [banner_line]
    lines << center(context.entity || 'Unspecified Entity')
    lines << center('Multi Document Transaction Report')
    lines << center('Sorted by Amount Descending') if sort_by == :amount
    lines << ''
    lines << center('Source Documents:')
    lines << ''
    context.journals.each do |document|
      short_name = SHORT_NAME_FORMAT_STRING % document.short_name
      lines << center("#{short_name} -- #{document.title}")
    end
    lines << banner_line
    lines << ''
    lines << '   Date     Document           Amount      Account'
    lines << '   ----     --------           ------      -------'
    lines.join("\n") << "\n\n"
  end


  def generate_report(filter = nil, sort_by = :date_and_account)
    unless SORT_BY_VALID_OPTIONS.include?(sort_by)
      raise Error.new("sort_by option '#{sort_by}' not in valid choices of #{SORT_BY_VALID_OPTIONS}.")
    end

    entries = Journal.entries_in_documents(context.journals, filter)

    if sort_by == :amount
      JournalEntry.sort_entries_by_amount_descending!(entries)
    end

    sio = StringIO.new
    sio << generate_header(sort_by)
    entries.each { |entry| sio << format_multidoc_entry(entry) << "\n" }

    totals = AcctAmount.aggregate_amounts_by_account(JournalEntry.entries_acct_amounts(entries))
    sio << generate_and_format_totals('Totals', totals)

    sio << "\n"
    sio.string
  end


  alias_method :to_s, :generate_report
  alias_method :call, :generate_report
end
end
