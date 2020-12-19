require_relative 'bs_is_section_data'
require_relative '../filters/journal_entry_filters'
require_relative '../documents/journal'
require_relative 'report_context'

module RockBooks
class BalanceSheetData

  attr_reader :acct_totals, :context, :end_date, :totals

  def initialize(context)
    @context = context
    @end_date = context.chart_of_accounts.end_date
    filter = JournalEntryFilters.date_on_or_before(end_date)
    acct_amounts = Journal.acct_amounts_in_documents(context.journals, filter)
    @acct_totals = AcctAmount.aggregate_amounts_by_account(acct_amounts)
  end


  def section_data(type)
    BsIsSectionData.new(type, context, acct_totals).call
  end


  def call
    {
        asset:     section_data(:asset),
        liability: section_data(:liability),
        equity:    section_data(:equity),
        grand_total: acct_totals.values.sum.round(2)
    }
  end
end
end
