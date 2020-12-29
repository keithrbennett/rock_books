require_relative 'data/tx_one_account_data'
require_relative '../documents/chart_of_accounts'
require_relative '../documents/journal'
require_relative 'helpers/erb_helper'
require_relative 'helpers/reporter'
require_relative 'report_context'

module RockBooks

  class TxOneAccount

    include Reporter
    include ErbHelper

    attr_reader :context, :account_code, :data


    def initialize(data, report_context)
      @data = data
      @context = report_context
    end


    def generate
      ErbHelper.render_hashes('text/tx_one_account.txt.erb', data, template_presentation_context)
    end
  end
end
