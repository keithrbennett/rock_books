module RockBooks

class JournalEntryContext < Struct.new(:journal, :linenum, :line)

  def chart_of_accounts
    journal.chart_of_accounts
  end

  def to_s
    "Journal '#{journal.short_name}', line ##{linenum}, text: #{line}"
  end
end

end
