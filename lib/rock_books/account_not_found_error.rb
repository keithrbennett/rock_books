module RockBooks
class AccountNotFoundError < RuntimeError

  attr_accessor :bad_account_code, :document_name, :line

  def initialize(bad_account_code, document_name = nil, line = nil)
    super
    self.bad_account_code = bad_account_code
  end


  def to_s
    "Account code not found in chart of accounts: #{bad_account_code}, document: #{document_name}, line: #{line}"
  end
end
end
