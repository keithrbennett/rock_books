module RockBooks

  # Reports the income statement for the specified date range.
class IncomeStatement < Struct.new(:chart_of_accounts, :journals, :start_date, :end_date, :page_width)

  include Reporter

  def initialize(chart_of_accounts, journals, start_date = Date.new, end_date = Time.now.to_date, page_width = 80)
    super
  end


  def format_header
    <<~HEREDOC
    #{banner_line}
    #{center("Income Statement -- #{start_date} to #{end_date}")}
    #{banner_line}

    HEREDOC
  end


  def generate_report
    filter = RockBooks::JournalEntryFilters.date_in_range(start_date, end_date)
    acct_amounts = acct_amounts_in_documents(journals, filter)
    totals = AcctAmount.aggregate_amounts_by_account(acct_amounts)
    totals.each { |aa| aa[1] = -aa[1] } # income statement shows credits as positive, debits as negative
    output = format_header

    income_output,  income_total  = generate_account_type_section('Income',   totals, :income,  true)
    expense_output, expense_total = generate_account_type_section('Expenses', totals, :expense, false)

    grand_total = income_total - expense_total

    output << [income_output, expense_output].join("\n\n")
    output << "\n#{"%12.2f    Net Income" % grand_total}\n============\n"
    output
  end

alias_method :to_s, :generate_report
alias_method :call, :generate_report


end
end
