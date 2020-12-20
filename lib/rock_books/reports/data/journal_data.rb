require_relative '../../types/acct_amount'

module RockBooks
class JournalData

  attr_reader :journal, :context, :filter

  def initialize(journal, report_context, filter = nil)
    @journal = journal
    @context = report_context
    @filter = filter
  end

  def entries
    return @entries if @entries
    @entries = journal.entries
    @entries.select! { |entry| filter.(entry) } if filter
    @entries
  end

  def call
    {
      code: journal.account_code,
      name: journal.chart_of_accounts.name_for_code(journal.account_code),
      short_name: journal.short_name,
      start_date: context.chart_of_accounts.start_date,
      end_date: context.chart_of_accounts.end_date,
      entity: context.entity,
      entries: entries,
      totals: AcctAmount.aggregate_amounts_by_account(JournalEntry.entries_acct_amounts(entries)),
      max_acct_code_len: context.chart_of_accounts.max_account_code_length
    }
  end
end
end
