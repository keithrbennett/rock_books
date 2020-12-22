require_relative '../../documents/journal'
require_relative '../../documents/journal_entry'

module RockBooks
class MultidocTransactionReportData

  attr_reader :context, :entries, :totals

  def initialize(context, sort_by, filter = nil)
    @context = context
    @entries = fetch_entries(sort_by, filter)
    @totals = fetch_totals(filter)
  end

  def fetch
    {
      entries: entries,
      totals: totals,
      grand_total: totals.values.sum.round(2)
    }
  end

  private def fetch_entries(sort_by, filter)
    entries = Journal.entries_in_documents(context.journals, filter)
    if sort_by == :amount
      JournalEntry.sort_entries_by_amount_descending!(entries)
    else
      JournalEntry.sort_entries_by_date!(entries)
    end
    entries
  end

  private def fetch_totals(filter)
    acct_amounts = Journal.acct_amounts_in_documents(context.journals, filter)
    AcctAmount.aggregate_amounts_by_account(acct_amounts)
  end
end
end
