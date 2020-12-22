require_relative '../documents/chart_of_accounts'
require_relative '../documents/journal'
require_relative 'helpers/reporter'
require_relative 'report_context'
require_relative 'data/multidoc_txn_by_account_data'

module RockBooks

class MultidocTransactionByAccountReport

  include Reporter

  attr_reader :context, :data


  def initialize(report_context)
    @context = report_context
    @data = MultidocTxnByAccountData.new(context).fetch
  end

  def account_total_line(account_code, account_total)
    account_name = context.chart_of_accounts.name_for_code(account_code)
    "%.2f  Total for account: %s - %s" % [account_total, account_code, account_name]
  end

  def generate
    erb_render('multidoc_txn_by_account_report.txt.erb')
  end
end
end
