require_relative 'reporter'
require_relative 'report_context'

module RockBooks

  class TransactionSummary < Struct.new(:document, :chart_of_accounts, :page_width)

    include Reporter

    attr_accessor :journal, :context

    def initialize(journal, report_context)
      @journal = journal
      @context = report_context
    end


    def format_entry(code, amount)
      [
          format_amount(amount),
          format_account_code(code),
          chart_of_accounts.name_for_code(code)
      ].join('   ')
    end


    def generate_header
      code = journal.account_code
      name = journal.chart_of_accounts.name_for_code(code)
      title = "Summary of Transactions for Account ##{code} -- #{name}"

      <<~HEREDOC
      #{banner_line}
      #{center(title)}
      #{banner_line}

      HEREDOC
    end


    def generate_report
      sio = StringIO.new
      sio << generate_header

      totals_by_account = AcctAmount.aggregate_amounts_by_account(journal.acct_amounts)

      totals_by_account.each do |code, amount|
        sio << format_entry(code, amount) << "\n"
      end

      sio << banner_line << "\n"
      sio << format_amount(journal.total_amount) << '   TOTAL'
      sio.string
    end


    alias_method :to_s, :generate_report
    alias_method :call, :generate_report
  end

end