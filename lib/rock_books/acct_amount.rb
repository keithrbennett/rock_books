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

  def self.total_amount(acct_amounts)
    acct_amounts.inject(0) { |sum, acct_amount| sum += acct_amount.amount }
  end


  # Returns a hash whose keys are account codes and values are the totals for those codes.
  # The 'aggregate' in the method name is intended to be a noun, not a verb.
  def self.aggregate_amounts_by_account(acct_amounts)
    acct_amounts.each_with_object(Hash.new(0)) do |acct_amount, by_account|
      by_account[acct_amount.code] += acct_amount.amount
    end
  end
end
end
