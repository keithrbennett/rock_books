module RockBooks

class JournalEntry < Struct.new(:date, :acct_amounts, :description, :doc_short_name)

  def self.entries_acct_amounts(entries)
    acct_amounts = entries.each_with_object([]) do |entry, acct_amounts|
      acct_amounts << entry.acct_amounts
    end
    acct_amounts.flatten!
    acct_amounts
  end


  def total_amount
    acct_amounts.inject(0) { |sum, aa| sum + aa.amount }
  end


  def balanced?
    total_amount == 0.0
  end
end

end
