require_relative 'helpers/bs_is_report_helper'
require_relative 'data/bs_is_data'
require_relative '../documents/journal'
require_relative 'report_context'

module RockBooks


  class IncomeStatement

  include Reporter
  include BsIsReportHelper

  attr_accessor :context, :data


  def initialize(report_context)
    @context = report_context
    @data = BsIsData.new(context).inc_stat_data
  end


  def erb_report_template
    read_template('income_statement.txt.erb')
  end

end
end
