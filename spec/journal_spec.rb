require_relative '../lib/primordial_books/journal'

module PrimordialBooks

  RSpec.describe PrimordialBooks::Journal do

    CHART_OF_ACCOUNTS = ChartOfAccounts.new("101 Cash in Bank, 201 Accounts Payable")
    EMPTY_JOURNAL = Journal.new(CHART_OF_ACCOUNTS, "@account_code: 101")
    TEST_DATE = Date.iso8601('2018-05-13')

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
      chart_of_accounts = ChartOfAccounts.new("101 D Cash in Bank\n201 C Accounts Payable")
      data = "@account_code: 101\n2018-05-13 333.33  201"
      journal_entry = Journal.new(chart_of_accounts, data).entries.first
      expect(journal_entry.date.to_s).to eq('2018-05-13')

      date = Date.iso8601('2018-05-13')
      expected = [AcctAmount.new(TEST_DATE, '101', 333.33), AcctAmount.new(date, '201', -333.33)]
      expect(journal_entry.acct_amounts).to eq(expected)
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

    it 'parses account tokens correctly with only account number' do
      expected = [AcctAmount.new(TEST_DATE, '101', -7.89), AcctAmount.new(TEST_DATE, '909', 7.89)]
      expect(EMPTY_JOURNAL.build_acct_amount_array(TEST_DATE, %w(7.89  909))).to eq(expected)
    end

    it 'parses account tokens correctly with pairs' do
      expected = [
          AcctAmount.new(TEST_DATE, '101', -3.75),
          AcctAmount.new(TEST_DATE, '888', 1.25),
          AcctAmount.new(TEST_DATE, '999', 2.50)
      ]
      expect(EMPTY_JOURNAL.build_acct_amount_array(TEST_DATE, %w(3.75  888  1.25  999  2.50))).to eq(expected)
    end

    it 'raises an error when an even number of tokens greater than 0 is passed' do
      expect { EMPTY_JOURNAL.build_acct_amount_array(TEST_DATE, %w(8.88  201  4.44  202)) }.to raise_error(RuntimeError)
    end


  end
end
