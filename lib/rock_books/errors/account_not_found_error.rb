require_relative '../types/journal_entry_context'


module RockBooks
class AccountNotFoundError < RuntimeError

  attr_accessor :code, :journal_entry_context

  def initialize(code, journal_entry_context)
    self.code = code
    self.journal_entry_context = journal_entry_context
    super(to_s)
  end


  def to_s
    ctx = journal_entry_context
    "Account code '#{code}' in journal '#{ctx.journal.short_name}', line ##{ctx.linenum} not found in chart of accounts. Line: '#{ctx.line}'"
  end
end
end
