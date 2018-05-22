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


end
end

