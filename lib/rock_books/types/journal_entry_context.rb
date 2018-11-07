module RockBooks

class JournalEntryContext < Struct.new(:journal, :linenum, :line)

  def chart_of_accounts
    journal.chart_of_accounts
  end
end

end
