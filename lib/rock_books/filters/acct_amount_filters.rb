module RockBooks
module AcctAmountFilters

  module_function

  def account_code(code)
    ->(acct_amount) { acct_amount.code == code }
  end


end
end