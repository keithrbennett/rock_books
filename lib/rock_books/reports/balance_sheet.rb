module RockBooks
class BalanceSheet

  include Reporter

  attr_reader :end_date


  def initialize(chart_of_accounts, end_date)
    @chart_of_accounts = chart_of_accounts
    @end_date = end_date
  end


  def format_header
    <<~HEREDOC
    #{banner_line}
    #{center("Balance Sheet -- #{end_date}")}
    #{banner_line}

    HEREDOC
  end


end
end
