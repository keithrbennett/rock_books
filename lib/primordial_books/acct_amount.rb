module PrimordialBooks

# This class represents an account id and an amount.
# Journal entries will have multiple instances of these.
class AcctAmount < Struct.new(:acct_id, :amount)

  # Returns an array of AcctAmount instances for the array of tokens. Examples:
  # ['101', 1.23, '201', 4.56] --> [AcctAmount id: '101', amount: 1.23, AcctAmount id: '201', 4.56]
  # shortcut: if there is only 1 account, give it the total amount
  # ['101'] --> [AcctAmount id: '101', total_amount]
  def self.parse_tokens(tokens, total_amount)
    if tokens.size == 1
      [AcctAmount.new(tokens.first, total_amount)]
    elsif tokens.size.odd?
      raise "Token list size must be 1 or even: #{tokens}"
    else
      tokens.each_slice(2).map { |pair| AcctAmount.new(pair.first, pair.last)}
    end
  end
end
end
