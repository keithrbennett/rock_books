require_relative 'data/tx_one_account_data'
require_relative '../documents/chart_of_accounts'
require_relative '../documents/journal'
require_relative 'helpers/reporter'
require_relative 'report_context'

module RockBooks

  class TxOneAccount

    include Reporter

    attr_reader :context, :account_code, :data


    def initialize(report_context, account_code)
      @context = report_context
      @account_code = account_code
      @data = TxOneAccountData.new(context, account_code).fetch
    end


    def generate
      erb_render('tx_one_account.txt.erb')
    end
  end
end
