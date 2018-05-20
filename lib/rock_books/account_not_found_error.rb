module RockBooks
class AccountNotFoundError < RuntimeError

  attr_accessor :bad_account_code

  def initialize(bad_account_code)
    super("Account code not found in chart of accounts: #{bad_account_code}" )
    self.bad_account_code = bad_account_code
  end
end
end
