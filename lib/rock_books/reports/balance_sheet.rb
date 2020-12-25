require_relative 'helpers/erb_helper'
require_relative 'helpers/reporter'

module RockBooks

# Reports the balance sheet as of the specified date.
# Unlike other reports, we need to process transactions from the beginning of time
# in order to calculate the correct balances, so we ignore the global $filter.
class BalanceSheet

  include Reporter
  include ErbHelper

  attr_accessor :context, :data

  def initialize(report_context, data)
    @context = report_context
    @data = data
  end


  def generate
    ErbHelper.render_hashes('balance_sheet.txt.erb', data, template_presentation_context)
  end
end
end
