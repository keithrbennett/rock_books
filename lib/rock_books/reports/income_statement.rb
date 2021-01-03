require_relative 'helpers/erb_helper'
require_relative 'helpers/text_report_helper'

module RockBooks


  class IncomeStatement

  include TextReportHelper
  include ErbHelper

  attr_reader :data, :context


  def initialize(report_context, data)
    @context = report_context
    @data = data
  end


  def generate
    ErbHelper.render_hashes('text/income_statement.txt.erb', data, template_presentation_context)
  end
end
end
