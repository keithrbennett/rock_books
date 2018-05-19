module RockBooks

# This class represents an account id and an amount.
# Journal entries will have multiple instances of these.
class AcctAmount < Struct.new(:date, :acct_id, :amount)

  # Same as constructor except it raises an error if the account id is not in the chart of accounts.
  def self.create_with_chart_validation(date, acct_id, amount, chart_of_accounts)
    unless chart_of_accounts.include?(acct_id)
      raise AccountNotFoundError.new(acct_id)
    end
    self.new(date, acct_id, amount)
  end
end
end
