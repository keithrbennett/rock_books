module RockBooks

# This class represents an account id and an amount.
# Journal entries will have multiple instances of these.
class AcctAmount < Struct.new(:date, :acct_id, :amount)
end
end
