require 'awesome_print'

require_relative 'chart_of_accounts'
require_relative 'journal'
require_relative '../filters/journal_entry_filters'  # for shell mode
require_relative '../helpers/parse_helper'
require_relative '../reports/balance_sheet'
require_relative '../reports/income_statement'
require_relative '../reports/multidoc_transaction_report'
require_relative '../reports/transaction_report'
require_relative '../reports/tx_by_account'

module RockBooks

  class BookSet < Struct.new(:chart_of_accounts, :journals)

    FILTERS = JournalEntryFilters


    def multidoc_transaction_report(filter)
      MultidocTransactionReport.new(chart_of_accounts, journals).call(filter)
    end


    def singledoc_transaction_report(journal, filter)
      TransactionReport.new(chart_of_accounts, journal).call(filter)
    end


    def balance_sheet_report(journals)    # TODO: date params
      BalanceSheet.new(chart_of_accounts, journals).call
    end


    def income_statement_report(journals)   # TODO: date params
      IncomeStatement.new(chart_of_accounts, journals).call
    end

    def all_txns_by_account(chart_of_accounts, journals)

    end


    def all_reports(filter = nil)
      report_hash = journals.each_with_object({}) do |journal, report_hash|
        report_hash[journal.short_name] = singledoc_transaction_report(journal, filter)
      end
      report_hash['all'] = multidoc_transaction_report(filter)
      report_hash['tx_by_account'] = TxByAccount.new(chart_of_accounts, journals)
      report_hash['balance_sheet'] = balance_sheet_report(journals)
      report_hash['income_statement'] = income_statement_report(journals)
      report_hash['all_txns_by_acct'] = all_txns_by_account(chart_of_accounts, journals)

      report_hash
    end


    def all_reports_to_files(directory = '.', filter = nil)
      reports = all_reports(filter)
      reports.each do |short_name, report_text|
        filespec = File.join(directory, "#{short_name}.rpt")
        File.write(filespec, report_text)
        puts "Created report for #{short_name} at #{filespec}."
      end
    end


    def journal_names
      journals.map(&:short_name)
    end
    alias_method :jnames, :journal_names
  end

end
