require_relative 'data/bs_is_data'
require_relative '../documents/journal'
require_relative 'report_context'

module RockBooks


  class IncomeStatement

  include Reporter

  attr_accessor :context, :data


  def initialize(report_context, data)
    @context = report_context
    @data = data
  end


  def generate
    erb_render('income_statement.txt.erb')
  end
end
end
