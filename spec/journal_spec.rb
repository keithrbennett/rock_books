require_relative '../lib/primordial_books/journal'

module PrimordialBooks

  RSpec.describe PrimordialBooks::Journal do

    it "can be instantiated" do
      expect(Journal.new(nil, '')).not_to be nil
    end

    it 'can read its title' do
      data = '@title: ABC Checking Account'
      expect(Journal.new(nil, data).title).to eq('ABC Checking Account')
    end

    it 'can read its date prefix' do
      data = '@date_prefix: 2018-'
      expect(Journal.new(nil, data).date_prefix).to eq('2018-')
    end

    it 'correctly handles doc_type' do
      data = "@doc_type: journal\n"
      expect(Journal.new(nil, data).doc_type).to eq('journal')
    end

    it 'correctly parses a journal entry without a split and without a description' do
      data = "2018-05-13 333.33  333"
      journal_entry = Journal.new(nil, data).entries.first
      expect(journal_entry.date.to_s).to eq('2018-05-13')
      expect(journal_entry.acct_amounts).to eq([AcctAmount.new(Date.iso8601('2018-05-13'), '333', 333.33)])
    end

    it 'correctly determines the main journal account' do
      data = '@account_code: 101 '
      chart_of_accounts = ChartOfAccounts.new('101 D Cash in Bank')
      expect(Journal.new(chart_of_accounts, data).account_code).to eq('101')
    end

    it 'raises an error when the journal account code is not present in the chart of accounts.' do
      chart_of_accounts = ChartOfAccounts.new('101 D Cash in Bank')
      data = '@account_code: 999'
      expect { Journal.new(chart_of_accounts, data) }.to raise_error(Error)
    end
  end
end
