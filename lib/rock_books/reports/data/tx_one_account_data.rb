module RockBooks
  class TxOneAccountData

    include TextReportHelper

    attr_reader :context, :account_code, :account, :entries, :account_total, :totals


    def initialize(report_context, account_code)
      @context = report_context
      @account_code = account_code
    end

    def fetch

      account = context.chart_of_accounts.account_for_code(account_code)
      account_string = "#{account.code} -- #{account.name}  (#{account.type.to_s.capitalize})"
      entries = Journal.entries_in_documents(context.journals, JournalEntryFilters.account_code(account_code))
      account_total = JournalEntry.total_for_code(entries, account_code)
      totals = AcctAmount.aggregate_amounts_by_account(JournalEntry.entries_acct_amounts(entries))


      {
        account_string: account_string,
        entries: entries,
        total: account_total,
        totals: AcctAmount.aggregate_amounts_by_account(JournalEntry.entries_acct_amounts(entries)),
        grand_total: totals.values.sum.round(2)
      }
    end

    private def fetch_totals(filter)
      acct_amounts = Journal.acct_amounts_in_documents(context.journals, filter)
      AcctAmount.aggregate_amounts_by_account(acct_amounts)
    end
  end
end
