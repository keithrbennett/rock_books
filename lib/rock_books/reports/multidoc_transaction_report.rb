require_relative 'data/multidoc_transaction_report_data'
require_relative '../documents/journal'
require_relative 'helpers/reporter'
require_relative 'report_context'

module RockBooks

class MultidocTransactionReport

  include Reporter

  attr_reader :context, :data

  SORT_BY_VALID_OPTIONS = %i(date  amount)

  def initialize(report_context, sort_by, filter = nil)
    unless SORT_BY_VALID_OPTIONS.include?(sort_by)
      raise Error.new("sort_by option '#{sort_by}' not in valid choices of #{SORT_BY_VALID_OPTIONS}.")
    end
    @context = report_context
    @data = MultidocTransactionReportData.new(context, sort_by, filter).fetch
  end


  def generate_header
    lines = [banner_line]
    lines << center(context.entity || 'Unspecified Entity')
    lines << center('Multi Document Transaction Report')
    lines << center('Sorted by Amount Descending') if sort_by == :amount
    lines << ''
    lines << center('Source Documents:')
    lines << ''
    context.journals.each do |journal|
      short_name = SHORT_NAME_FORMAT_STRING % journal.short_name
      lines << center("#{short_name} -- #{journal.title}")
    end
    lines << banner_line
    lines << ''
    lines << '   Date     Document           Amount      Account'
    lines << '   ----     --------           ------      -------'
    lines.join("\n") << "\n\n"
  end


  def generate
    erb_render('multidoc_txn_report.txt.erb')
  end
end
end
