require_relative 'spec_helper'
require_relative 'samples'
require_relative '../lib/rock_books/journal'
require 'awesome_print'

module RockBooks

  RSpec.describe RockBooks::Journal do

    TEST_DATE = Date.iso8601('2018-05-13')

    it "can be instantiated" do
      expect(Journal.new(nil, '')).not_to be nil
    end

    it 'can read its title' do
      title = 'ABC Checking Account'
      data = '@title: ' + title
      expect(Journal.new(nil, data).title).to eq(title)
    end

    it 'can read its date prefix' do
      date_prefix = '2018-'
      data = '@date_prefix: ' + date_prefix
      expect(Journal.new(nil, data).date_prefix).to eq(date_prefix)
    end

    it 'correctly handles doc_type' do
      doc_type = 'journal'
      data = '@doc_type: ' + doc_type
      expect(Journal.new(nil, data).doc_type).to eq(doc_type)
    end

    it 'correctly parses a journal entry without a split and without a description' do
      chart_of_accounts = ChartOfAccounts.new("101 A Cash in Bank\n201 L Accounts Payable")
      data = "@account_code: 101\n#{TEST_DATE} 333.33  201"
      journal_entry = Journal.new(chart_of_accounts, data).entries.first
      expect(journal_entry.date).to eq(TEST_DATE)

      expected = [
          AcctAmount.new(TEST_DATE, '101', -333.33),
          AcctAmount.new(TEST_DATE, '201', 333.33)]
      expect(journal_entry.acct_amounts).to eq(expected)
    end

    it 'correctly determines the main journal account' do
      acct_code = '101'
      data = '@account_code: ' + acct_code
      chart_of_accounts = ChartOfAccounts.new(acct_code + ' A Cash in Bank')
      expect(Journal.new(chart_of_accounts, data).account_code).to eq(acct_code)
    end

    it 'can produce JSON which can then be parsed and entries contain the expect values' do
      account_code = '101'
      data = "@account_code: #{account_code}\n2018-05-13 333.33  201"
      journal = Journal.new(Samples.chart_of_accounts, data)

      parsed_code = JSON.parse(journal.to_json)["account_code"]
      expect(parsed_code).to eq(account_code)
    end

    it 'can produce YAML which can then be parsed and entries contain the expected values' do

      acct_code_1 = '101'
      acct_code_2 = '201'

      data = "@account_code: #{acct_code_1}\n2018-05-13 333.33  #{acct_code_2}"

      journal = Journal.new(Samples.chart_of_accounts, data)
      parsed_journal = YAML.load(journal.to_yaml)

      parsed_journal_code = parsed_journal[:account_code]
      expect(parsed_journal_code).to eq(acct_code_1)

      parsed_second_code = parsed_journal[:entries].first.acct_amounts[1].code
      expect(parsed_second_code).to eq(acct_code_2)
    end

    it 'can include a 1-line description' do
      description = "Office Depot - Stapler, Shredder, Vacuum Cleaner"
      data = "@account_code: 101\n2018-05-13 14.79  701\n#{description}\n2018-05-14  32.11  702\n"
      journal = Journal.new(Samples.chart_of_accounts, data)
      expect(journal.entries.first.description).to start_with(description)
    end

    it 'can include a 2-line description' do
      description = "Office Depot - Stapler, Shredder, Vacuum Cleaner,\nPrinter paper, pens"
      data = "@account_code: 101\n2018-05-13 14.79  701\n#{description}\n2018-05-14  32.11  702\n"
      journal = Journal.new(Samples.chart_of_accounts, data)
      expect(journal.entries.first.description).to start_with(description)
    end


    it 'can produce an array of all the AcctAmounts for the journal' do
      data = "@account_code: 101\n@date_prefix: 2018-05-\n01  1.00  701\n"
      journal = Journal.new(Samples.chart_of_accounts, data)
      expected = [
          AcctAmount.new(Date.iso8601('2018-05-01'), '101', -1.00),
          AcctAmount.new(Date.iso8601('2018-05-01'), '701', 1.00),
      ]
      expect(journal.acct_amounts).to eq(expected)
    end

    it 'can produce totals by account' do
      data = "@account_code: 101\n2018-05-13 1.00  701\n2018-05-14  10.00  702\n" \
          << "2018-05-14  20.00  703\n\n2018-05-14  100.00  703"
      journal = Journal.new(Samples.chart_of_accounts, data)
      totals = journal.totals_by_account
      expect(totals['101']).to eq(-131.00)
      expect(totals['701']).to eq(1.00)
      expect(totals['702']).to eq(10.00)
      expect(totals['703']).to eq(120.00)
    end

    it %q{raises an error when an journal's main account code does not exist} do
      bad_account_code = '666'
      data = "@account_code: #{bad_account_code}\n2018-05-13 1.00  701"
      expect { Journal.new(Samples.chart_of_accounts, data) }.to raise_error(AccountNotFoundError)
    end

    it %q{raises an error when an entry's account code does not exist} do
      bad_account_code = '666'
      data = "@account_code: 101\n2018-05-13 1.00  #{bad_account_code}"
      expect { Journal.new(Samples.chart_of_accounts, data) }.to raise_error(AccountNotFoundError)
    end

    it 'returns the correct transaction total of zero' do
      data = "@account_code: 101\n@date_prefix: 2018-05-\n01  1.00  701\n"
      journal = Journal.new(Samples.chart_of_accounts, data)
      expect(journal.total_amount).to eq(0)
    end

    it 'returns the correct transaction total of non-zero when debit/credit is specified in journal' do
      data = "@account_code: 101\n@date_prefix: 2018-05-\n@debit_or_credit: debit\n01  100.00  701  10.00\n"
      journal = Journal.new(Samples.chart_of_accounts, data)
      expect(journal.total_amount).to eq(-90.0)
    end

    it 'returns the correct transaction total of non-zero when debit/credit is specified in chart of accounts' do
      data = "@account_code: 101\n@date_prefix: 2018-05-\n01  100.00  701  10.00\n"
      journal = Journal.new(Samples.chart_of_accounts, data)
      expect(journal.total_amount).to eq(-90.0)
    end

    it 'inherits the debit/credit state of the main account when not specified in the journal' do
      data = "@account_code: 101\n2018-05-01  100.00  701  10.00\n"
      journal = Journal.new(Samples.chart_of_accounts, data)
      expect(journal.debit_or_credit).to eq(:debit)
    end


  end
end
