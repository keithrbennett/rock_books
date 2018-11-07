require_relative '../errors/transaction_not_balanced_error'

module RockBooks

class TransactionNotBalancedError < RuntimeError

    attr_reader :discrepancy, :journal_entry_context

    def initialize(discrepancy, journal_entry_context)
      @discrepancy = discrepancy
      @journal_entry_context = journal_entry_context
      super(to_s)
    end

    def to_s
      "Transaction not balanced; discrepancy is #{discrepancy}. Context: #{journal_entry_context}"
    end
end

end