module RockBooks
module Reporter

  module_function

  def format_account_code(code)
    "%*.*s" % [max_account_code_length, max_account_code_length, code]
  end


  def format_amount(amount)
    "%9.2f" % amount
  end


  def banner_line
    @banner_line ||= '-' * page_width
  end


  def center(string)
    (' ' * ((page_width - string.length) / 2)) + string
  end


  def max_account_code_length
    @max_account_code_length ||= chart_of_accounts.max_account_code_length
  end


  def generate_and_format_totals(acct_amounts, chart_of_accounts)
    totals = AcctAmount.aggregate_amounts_by_account(acct_amounts)
    output = "Totals by Account\n-----------------\n\n"
    totals.each do |account_code, account_total|
      account_name = chart_of_accounts.name_for_code(account_code)
      output << "%12.2f   %12s   %s\n" % [account_total, account_code, account_name]
    end
    output << "------------\n"
    output << "%12.2f\n" % totals.values.sum.round(2)
    output
  end
end
end

