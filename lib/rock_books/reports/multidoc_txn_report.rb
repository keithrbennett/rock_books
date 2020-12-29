require_relative 'data/multidoc_txn_report_data'
require_relative '../documents/journal'
require_relative 'helpers/erb_helper'
require_relative 'helpers/reporter'
require_relative 'report_context'

module RockBooks

class MultidocTransactionReport

  include Reporter
  include ErbHelper

  attr_reader :context, :data

  def initialize(report_data, report_context)
    @data = report_data
    @context = report_context
  end

  def generate
    ErbHelper.render_hashes('text/multidoc_txn_report.txt.erb', data, template_presentation_context)
  end
end
end
