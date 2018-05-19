module RockBooks
class AccountNotFoundError < RuntimeError

  attr_accessor :bad_account_id

  def initialize(bad_account_id)
    super("Account id not found in chart of accounts: #{bad_account_id}" )
    self.bad_account_id = bad_account_id
  end
end
end
