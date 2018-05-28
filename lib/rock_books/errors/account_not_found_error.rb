module RockBooks
class AccountNotFoundError < RuntimeError

  attr_accessor :bad_account_code, :document_name, :line

  def initialize(bad_account_code, document_name = nil, line = nil)
    self.bad_account_code = bad_account_code
    super(to_s)
  end


  def to_s
    s = "Account code not found in chart of accounts: #{bad_account_code}"
    if document_name && line
      s << ", document: #{document_name}, line: #{line}"
    end
    s
  end
end
end
