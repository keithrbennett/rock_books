require_relative 'data/multidoc_txn_report_data'
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
    @data = MultidocTxnReportData.new(context, sort_by, filter).fetch
  end

  def generate
    erb_render('multidoc_txn_report.txt.erb', data, template_presentation_context)
  end
end
end
