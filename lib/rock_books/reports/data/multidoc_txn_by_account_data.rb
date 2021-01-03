module RockBooks
class MultidocTxnByAccountData

  include TextReportHelper

  attr_reader :context, :account_code


  def initialize(report_context)
    @context = report_context
  end


  def fetch
    all_journal_entries = Journal.entries_in_documents(context.journals)
    totals = AcctAmount.aggregate_amounts_by_account(JournalEntry.entries_acct_amounts(all_journal_entries))
    {
      journals: context.journals,
      entries: all_journal_entries,
      totals: totals,
      grand_total: totals.values.sum.round(2),
      acct_sections: fetch_acct_sections(all_journal_entries),
    }
  end


  private def fetch_acct_sections(all_journal_entries)
    context.chart_of_accounts.accounts.map do |account|
      code = account.code
      acct_entries = JournalEntry.entries_containing_account_code(all_journal_entries, code)
      total = JournalEntry.total_for_code(acct_entries, code)
      {
        code: code,
        entries: acct_entries,
        total: total
      }
    end
  end
end
end
