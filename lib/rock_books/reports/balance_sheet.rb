require_relative '../filters/journal_entry_filters'
require_relative '../documents/journal'
require_relative 'report_context'

module RockBooks

# Reports the balance sheet as of the specified date.
# Unlike other reports, we need to process transactions from the beginning of time
# in order to calculate the correct balances, so we ignore the global $filter.
class BalanceSheet

  include Reporter

  attr_accessor :context

  def initialize(report_context)
    @context = report_context
  end


  def end_date
    context.end_date || Time.new.to_date
  end


  def generate_header
    lines = [banner_line]
    lines << center(context.entity_name) if context.entity_name
    lines << center("Balance Sheet -- #{end_date}")
    lines << banner_line
    lines << ''
    lines << ''
    lines << ''
    lines.join("\n")
  end


 def generate_report
    filter = RockBooks::JournalEntryFilters.date_on_or_before(end_date)
    acct_amounts = Journal.acct_amounts_in_documents(context.journals, filter)
    totals = AcctAmount.aggregate_amounts_by_account(acct_amounts)
    output = generate_header

    asset_output,  asset_total  = generate_account_type_section('Assets',      totals, :asset,     false)
    liab_output,   liab_total   = generate_account_type_section('Liabilities', totals, :liability, true)
    equity_output, equity_total = generate_account_type_section('Equity',      totals, :equity,    true)

    output << [asset_output, liab_output, equity_output].join("\n\n")

    grand_total = asset_total - (liab_total + equity_total)

    output << "\n#{"%12.2f    Assets - (Liabilities + Equity)" % grand_total}\n============\n"
    output
  end

  alias_method :to_s, :generate_report
  alias_method :call, :generate_report

end
end
