module RockBooks

# This class represents an account code and an amount.
# Journal entries will have multiple instances of these.
class AcctAmount < Struct.new(:date, :code, :amount)


  # Same as constructor except it raises an error if the account code is not in the chart of accounts.
  def self.create_with_chart_validation(date, code, amount, chart_of_accounts)
    unless chart_of_accounts.include?(code)
      raise AccountNotFoundError.new(code)
    end
    self.new(date, code, amount)
  end
end
end
