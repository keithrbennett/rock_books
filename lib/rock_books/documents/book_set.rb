require 'awesome_print'

require_relative 'chart_of_accounts'
require_relative 'journal'
require_relative '../filters/journal_entry_filters'  # for shell mode
require_relative '../helpers/parse_helper'
require_relative '../reports/balance_sheet'
require_relative '../reports/income_statement'
require_relative '../reports/multidoc_transaction_report'
require_relative '../reports/report_context'
require_relative '../reports/transaction_report'
require_relative '../reports/tx_by_account'
require_relative '../reports/tx_one_account'

module RockBooks

  class BookSet < Struct.new(:entity_name, :chart_of_accounts, :journals)

    FILTERS = JournalEntryFilters

    def report_context
      @report_context ||= ReportContext.new(entity_name, chart_of_accounts, journals, nil, nil, 80)
    end


    def all_reports(filter = nil)
      context = report_context
      report_hash = context.journals.each_with_object({}) do |journal, report_hash|
        report_hash[journal.short_name] = TransactionReport.new(journal, context).call(filter)
      end
      report_hash['all_txns_by_date'] = MultidocTransactionReport.new(context).call(filter)
      report_hash['all_txns_by_amount'] = MultidocTransactionReport.new(context).call(filter, :amount)
      report_hash['all_txns_by_acct'] = TxByAccount.new(context).call
      report_hash['balance_sheet'] = BalanceSheet.new(context).call
      report_hash['income_statement'] = IncomeStatement.new(context).call

      chart_of_accounts.accounts.each do |account|
        key = 'acct_' + account.code
        report = TxOneAccount.new(context, account.code)
        report_hash[key] = report
      end
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


    # Note: Unfiltered!
    def all_acct_amounts
      @all_acct_amounts ||= Journal.acct_amounts_in_documents(journals)
    end

    def all_entries
      @all_entries ||= Journal.entries_in_documents(journals)
    end
end
end
