require 'rspec'

require_relative 'samples'
require_relative '../lib/rock_books/documents/journal'
require_relative '../lib/rock_books/documents/journal_entry'

module RockBooks

RSpec.describe RockBooks::JournalEntry do

  it 'should provide the correct values for total_amount and balanced? when zero' do
    gj_filespec = File.join(File.dirname(__FILE__), 'samples', 'general_journal.rdt')
    general_journal = Journal.from_file(Samples.chart_of_accounts, gj_filespec)
    journal_entry = general_journal.entries.first
    acct_amounts = journal_entry.acct_amounts
    expect(acct_amounts.map(&:amount)).to eq([1000.00, 2500.00, -500.00, -800.00, -2200.00])
    expect(journal_entry.total_amount).to eq(0)
    expect(journal_entry.balanced?).to eq(true)
  end


  it 'should provide the correct values for total_amount and balanced? when NOT zero' do
    gj_filespec = File.join(File.dirname(__FILE__), 'samples', 'general_journal.rdt')
    general_journal = Journal.from_file(Samples.chart_of_accounts, gj_filespec)
    journal_entry = general_journal.entries.first
    acct_amounts = journal_entry.acct_amounts
    acct_amounts.first.amount = 1001.00  # from 1000.00
    expect(acct_amounts.map(&:amount)).to eq([1001.00, 2500.00, -500.00, -800.00, -2200.00])
    expect(journal_entry.total_amount).to eq(1.00)
    expect(journal_entry.balanced?).to eq(false)
  end
end

end
