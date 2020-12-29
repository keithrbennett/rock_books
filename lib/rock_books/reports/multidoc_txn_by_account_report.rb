require_relative '../documents/chart_of_accounts'
require_relative 'helpers/erb_helper'
require_relative 'helpers/reporter'
require_relative 'report_context'
require_relative 'data/multidoc_txn_by_account_data'

module RockBooks

class MultidocTransactionByAccountReport

  include Reporter
  include ErbHelper

  attr_reader :context, :data


  def initialize(data, report_context)
    @data = data
    @context = report_context
  end

  def account_total_line(account_code, account_total)
    account_name = context.chart_of_accounts.name_for_code(account_code)
    "%.2f  Total for account: %s - %s" % [account_total, account_code, account_name]
  end

  def generate
    presentation_context = template_presentation_context.merge({ fn_account_total_line: method(:account_total_line) })
    ErbHelper.render_hashes('text/multidoc_txn_by_account_report.txt.erb', data, presentation_context)
  end
end
end
