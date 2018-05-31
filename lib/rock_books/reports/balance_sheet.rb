require_relative '../filters/journal_entry_filters'
require_relative '../documents/journal'

module RockBooks

# Reports the balance sheet as of the specified date.
# Unlike other reports, we need to process transactions from the beginning of time
# in order to calculate the correct balances, so we ignore the global $filter.
class BalanceSheet < Struct.new(:chart_of_accounts, :journals, :end_date, :page_width)

  include Reporter

  def initialize(chart_of_accounts, journals, end_date = Time.now.to_date, page_width = 80)
    super
  end


  def generate_header
    <<~HEREDOC
    #{banner_line}
    #{center("Balance Sheet -- #{end_date}")}
    #{banner_line}

    HEREDOC
  end


 def generate_report
    filter = RockBooks::JournalEntryFilters.date_on_or_before(end_date)
    acct_amounts = Journal.acct_amounts_in_documents(journals, filter)
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
