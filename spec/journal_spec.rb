require_relative '../lib/rock_books/journal'
require 'awesome_print'

module RockBooks

  RSpec.describe RockBooks::Journal do

    CHART_OF_ACCOUNTS = ChartOfAccounts.new(
        <<~HEREDOC
        101 D Cash in Bank
        201 C Accounts Payable
        301 C Owners Equity
        401 C Sales
        701 D Office Supplies
        702 D Rent
        703 D Professional Fees
        HEREDOC
    )
    EMPTY_JOURNAL = Journal.new(CHART_OF_ACCOUNTS, "@account_code: 101\n@debit_or_credit: debit")
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
      expected = [AcctAmount.new(TEST_DATE, '101', -333.33), AcctAmount.new(date, '201', 333.33)]
      expect(journal_entry.acct_amounts).to eq(expected)
    end

    it 'correctly determines the main journal account' do
      data = '@account_code: 101 '
      chart_of_accounts = ChartOfAccounts.new('101 D Cash in Bank')
      expect(Journal.new(chart_of_accounts, data).account_code).to eq('101')
    end

    it 'parses account tokens correctly with only account number' do
      expected = [
          AcctAmount.new(TEST_DATE, '101', -7.89),
          AcctAmount.new(TEST_DATE, '701', 7.89)
      ]
      actual = EMPTY_JOURNAL.build_acct_amount_array(TEST_DATE, %w(7.89  701), false)

      expect(actual[0]).to eq(expected[0])
      expect(actual[1]).to eq(expected[1])
      expect(actual).to eq(expected)
    end

    it 'parses account tokens correctly with pairs' do
      expected = [
          AcctAmount.new(TEST_DATE, '101', -3.75),
          AcctAmount.new(TEST_DATE, '888', 1.25),
          AcctAmount.new(TEST_DATE, '999', 2.50)
      ]
      expect(EMPTY_JOURNAL.build_acct_amount_array(TEST_DATE, %w(3.75  888  1.25  999  2.50), false)).to eq(expected)
    end

    it 'raises an error when an even number of tokens greater than 0 is passed' do
      expect { EMPTY_JOURNAL.build_acct_amount_array(TEST_DATE, %w(8.88  201  4.44  202), false) }.to raise_error(RuntimeError)
    end

    it 'can produce JSON which can then be parsed and entries contain the expect values' do
      account_code = '101'
      data = "@account_code: #{account_code}\n2018-05-13 333.33  201"
      journal = Journal.new(CHART_OF_ACCOUNTS, data)

      parsed_code = JSON.parse(journal.to_json)["account_code"]
      expect(parsed_code).to eq(account_code)
    end

    it 'can produce YAML which can then be parsed and entries contain the expected values' do

      first_entry_account_code = '101'
      second_entry_account_code = '201'

      data = "@account_code: #{first_entry_account_code}\n2018-05-13 333.33  #{second_entry_account_code}"

      journal = Journal.new(CHART_OF_ACCOUNTS, data)
      parsed_journal = YAML.load(journal.to_yaml)

      parsed_journal_code = parsed_journal[:account_code]
      expect(parsed_journal_code).to eq(first_entry_account_code)

      parsed_second_code = parsed_journal[:entries].first.acct_amounts[1].code
      expect(parsed_second_code).to eq(second_entry_account_code)
    end

    it 'can include a 1-line description' do
      description = "Office Depot - Stapler, Shredder, Vacuum Cleaner"
      data = "@account_code: 101\n2018-05-13 14.79  701\n#{description}\n2018-05-14  32.11  702\n"
      journal = Journal.new(CHART_OF_ACCOUNTS, data)
      expect(journal.entries.first.description).to start_with(description)
    end

    it 'can include a 2-line description' do
      description = "Office Depot - Stapler, Shredder, Vacuum Cleaner,\nPrinter paper, pens"
      data = "@account_code: 101\n2018-05-13 14.79  701\n#{description}\n2018-05-14  32.11  702\n"
      journal = Journal.new(CHART_OF_ACCOUNTS, data)
      expect(journal.entries.first.description).to start_with(description)
    end


    it 'can produce an array of all the AcctAmounts for the journal' do
      data = "@account_code: 101\n@date_prefix: 2018-05-\n01  1.00  701\n"
      journal = Journal.new(CHART_OF_ACCOUNTS, data)
      expected = [
          AcctAmount.new(Date.iso8601('2018-05-01'), '101', -1.00),
          AcctAmount.new(Date.iso8601('2018-05-01'), '701', 1.00),
      ]
      expect(journal.acct_amounts).to eq(expected)
    end

    it 'can produce totals by account' do
      data = "@account_code: 101\n2018-05-13 1.00  701\n2018-05-14  10.00  702\n" \
          << "2018-05-14  20.00  703\n\n2018-05-14  100.00  703"
      journal = Journal.new(CHART_OF_ACCOUNTS, data)
      totals = journal.totals_by_account
      expect(totals['101']).to eq(-131.00)
      expect(totals['701']).to eq(1.00)
      expect(totals['702']).to eq(10.00)
      expect(totals['703']).to eq(120.00)
    end

    it %q{raises an error when an journal's main account code does not exist} do
      bad_account_code = '666'
      data = "@account_code: #{bad_account_code}\n2018-05-13 1.00  701"
      expect { Journal.new(CHART_OF_ACCOUNTS, data) }.to raise_error(AccountNotFoundError)
    end

    it %q{raises an error when an entry's account code does not exist} do
      bad_account_code = '666'
      data = "@account_code: 101\n2018-05-13 1.00  #{bad_account_code}"
      expect { Journal.new(CHART_OF_ACCOUNTS, data) }.to raise_error(AccountNotFoundError)
    end

    it 'returns the correct transaction total of zero' do
      data = "@account_code: 101\n@date_prefix: 2018-05-\n01  1.00  701\n"
      journal = Journal.new(CHART_OF_ACCOUNTS, data)
      expect(journal.total_amount).to eq(0)
    end

    it 'returns the correct transaction total of non-zero' do
      data = "@account_code: 101\n@date_prefix: 2018-05-\n01  100.00  701  10.00\n"
      journal = Journal.new(CHART_OF_ACCOUNTS, data)
      expect(journal.total_amount).to eq(-90.0)
    end
  end
end
