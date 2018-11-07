module RockBooks

class TransactionNotBalancedError < RuntimeError

    attr_reader :discrepancy

    def initialize(discrepancy)
      @discrepancy = discrepancy
      super(to_s)
    end

    def to_s
      "Transaction not balanced; discrepancy is #{discrepancy}."
    end
end

end