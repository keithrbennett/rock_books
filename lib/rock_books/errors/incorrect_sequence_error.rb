require_relative '../types/journal_entry_context'


module RockBooks
  class IncorrectSequenceError < RuntimeError

    attr_accessor :tokens, :journal_entry_context

    def initialize(tokens, journal_entry_context)
      self.tokens = tokens
      self.journal_entry_context = journal_entry_context
      super(to_s)
    end


    def to_s
      ctx = journal_entry_context
      "Incorrect token sequence in journal '#{ctx.journal.short_name}', line ##{ctx.linenum}: #{tokens.inspect}"
    end
  end
end
