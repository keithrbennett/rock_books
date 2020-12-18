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
    Section.new(type, context, acct_totals).call
  end


  def call
    {
        asset:     section_data(:asset),
        liability: section_data(:liability),
        equity:    section_data(:equity),
        grand_total: acct_totals.values.sum.round(2)
    }
  end

  # End BalanceSheetData methods, start of inner class Section -------------------------------------------

  Section = Struct.new(:type, :context, :all_acct_totals)
  class Section

    def acct_codes
      @acct_codes ||= context.chart_of_accounts.account_codes_of_type(type)
    end

    def acct_totals
      all_acct_totals.select { |code, _amount| acct_codes.include?(code) }
    end

    def need_to_reverse_sign
      %i{liability equity}.include?(type)
    end

    def section_total
      acct_totals.map(&:last).sum.round(2)
    end

    def call
      if need_to_reverse_sign
        acct_totals.each { |code, amount| acct_totals[code] = -amount }
      end

      {
          acct_totals: acct_totals,
          total: section_total
      }
    end
  end
end
end
