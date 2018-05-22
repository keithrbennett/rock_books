module RockBooks

class JournalEntry < Struct.new(:date, :acct_amounts, :description)

  def total_amount
    acct_amounts.inject(0) { |sum, aa| sum + aa.amount }
  end

  def balanced?
    total_amount == 0.0
  end
end

end
