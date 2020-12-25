require_relative 'helpers/erb_helper'
require_relative 'helpers/reporter'

module RockBooks


  class IncomeStatement

  include Reporter
  include ErbHelper

  attr_reader :data, :context


  def initialize(report_context, data)
    @context = report_context
    @data = data
  end


  def generate
    ErbHelper.render_hashes('income_statement.txt.erb', data, template_presentation_context)
  end
end
end
