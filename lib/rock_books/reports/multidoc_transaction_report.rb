require_relative '../documents/journal'
require_relative 'reporter'
require_relative 'report_context'

module RockBooks

class MultidocTransactionReport

  include Reporter

  attr_accessor :context

  def initialize(report_context)
    @context = report_context
  end


  def generate_header
    lines = [banner_line]
    lines << center(context.entity_name) if context.entity_name
    lines << center('Multi Document Transaction Report')
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


  def generate_report(filter = nil)

    entries = Journal.entries_in_documents(context.journals, filter)

    sio = StringIO.new
    sio << generate_header
    entries.each { |entry| sio << format_multidoc_entry(entry) << "\n" }

    totals = AcctAmount.aggregate_amounts_by_account(JournalEntry.entries_acct_amounts(entries))
    sio << generate_and_format_totals('Totals', totals, context.chart_of_accounts)

    sio << "\n"
    sio.string
  end


  alias_method :to_s, :generate_report
  alias_method :call, :generate_report
end
end
