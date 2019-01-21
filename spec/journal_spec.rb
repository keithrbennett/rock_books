require_relative 'spec_helper'
require_relative 'samples'
require_relative '../lib/rock_books/documents/journal'
require 'awesome_print'

module RockBooks

  RSpec.describe RockBooks::Journal do

    TEST_DATE = Date.iso8601('2018-05-13')

    FN_CHART_OF_ACCOUNTS = -> do
      ChartOfAccounts.from_file(
        File.join(File.dirname(__FILE__), 'samples', 'chart_of_accounts.txt'))
    end


    it "can be instantiated" do
      expect(Journal.from_string(nil, '')).not_to be nil
    end

    it 'can read its title' do
      title = 'ABC Checking Account'
      data = '@title: ' + title
      expect(Journal.from_string(nil, data).title).to eq(title)
    end

    it 'can read its date prefix' do
      date_prefix = '2018-'
      data = '@date_prefix: ' + date_prefix
      expect(Journal.from_string(nil, data).date_prefix).to eq(date_prefix)
    end

    it 'correctly handles doc_type' do
      doc_type = 'journal'
      data = '@doc_type: ' + doc_type
      expect(Journal.from_string(nil, data).doc_type).to eq(doc_type)
    end

    it 'correctly parses a journal entry without a split and without a description' do
      data = "@account_code: ck.hsbc\n#{TEST_DATE} 333.33  loan.to.sh"
      journal_entry = Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data).entries.first
      expect(journal_entry.date).to eq(TEST_DATE)

      expected = [
          AcctAmount.new(TEST_DATE, 'ck.hsbc', -333.33),
          AcctAmount.new(TEST_DATE, 'loan.to.sh', 333.33)]
      expect(journal_entry.acct_amounts).to eq(expected)
    end

    it 'correctly determines the main journal account' do
      acct_code = 'ck.hsbc'
      data = '@account_code: ' + acct_code
      expect(Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data).account_code).to eq(acct_code)
    end

    it 'can produce JSON which can then be parsed and entries contain the expect values' do
      account_code = 'ck.hsbc'
      data = "@account_code: #{account_code}\n2018-05-13 333.33  loan.to.sh"
      journal = Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data)

      parsed_code = JSON.parse(journal.to_json)["account_code"]
      expect(parsed_code).to eq(account_code)
    end

    it 'can produce YAML which can then be parsed and entries contain the expected values' do

      acct_code_1 = 'ck.hsbc'
      acct_code_2 = 'loan.to.sh'

      data = "@account_code: #{acct_code_1}\n2018-05-13 333.33  #{acct_code_2}"

      journal = Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data)
      parsed_journal = YAML.load(journal.to_yaml)

      parsed_journal_code = parsed_journal[:account_code]
      expect(parsed_journal_code).to eq(acct_code_1)

      parsed_second_code = parsed_journal[:entries].first.acct_amounts[1].code
      expect(parsed_second_code).to eq(acct_code_2)
    end

    it 'can include a 1-line description' do
      description = "Office Depot - Stapler, Shredder, Vacuum Cleaner"
      data = "@account_code: ck.hsbc\n2018-05-13 14.79  supplies\n#{description}\n2018-05-14  32.11  ship.exp\n"
      journal = Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data)
      expect(journal.entries.first.description).to start_with(description)
    end

    it 'can include a 2-line description' do
      description = "Office Depot - Stapler, Shredder, Vacuum Cleaner,\nPrinter paper, pens"
      data = "@account_code: ck.hsbc\n2018-05-13 14.79  ship.exp\n#{description}\n2018-05-14  32.11  supplies\n"
      journal = Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data)
      expect(journal.entries.first.description).to start_with(description)
    end


    it 'can produce an array of all the AcctAmounts for the journal' do
      data = "@account_code: ck.hsbc\n@date_prefix: 2018-05-\n01  1.00  loan.to.sh\n"
      journal = Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data)
      expected = [
          AcctAmount.new(Date.iso8601('2018-05-01'), 'ck.hsbc',   -1.00),
          AcctAmount.new(Date.iso8601('2018-05-01'), 'loan.to.sh', 1.00),
      ]
      expect(journal.acct_amounts).to eq(expected)
    end

    it 'can produce totals by account' do
      data = "@account_code: ck.hsbc\n2018-05-13 1.00  supplies\n2018-05-14  10.00  ship.exp\n" \
          << "2018-05-14  20.00  misc.exp\n\n2018-05-14  100.00  misc.exp"
      journal = Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data)
      totals = journal.totals_by_account
      expect(totals['ck.hsbc']).to eq(-131.00)
      expect(totals['supplies']).to eq(1.00)
      expect(totals['ship.exp']).to eq(10.00)
      expect(totals['misc.exp']).to eq(120.00)
    end

    it %q{raises an error when an journal's main account code does not exist} do
      bad_account_code = '666'
      data = "@account_code: #{bad_account_code}\n2018-05-13 1.00  ship.exp"
      expect { Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data) }.to raise_error(AccountNotFoundError)
    end

    it %q{raises an error when an entry's account code does not exist} do
      bad_account_code = '666'
      data = "@account_code: ck.hsbc\n2018-05-13 1.00  #{bad_account_code}"
      expect { Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data) }.to raise_error(AccountNotFoundError)
    end

    it 'returns the correct transaction total of zero' do
      data = "@account_code: ck.hsbc\n@date_prefix: 2018-05-\n01  1.00  ship.exp\n"
      journal = Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data)
      expect(journal.total_amount).to eq(0)
    end

    it 'raises the correct negative error when an unbalanced transaction is specified in debit journal' do
      data = "@account_code: ck.hsbc\n@date_prefix: 2018-05-\n@debit_or_credit: debit\n01  100.00  ship.exp  10.00\n"
      create_bad_journal = -> { Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data) }
      expect { create_bad_journal.() }.to raise_error(TransactionNotBalancedError) do |error|
        expect(error.discrepancy).to eq(-90.0)
      end
    end

    it 'raises the correct positive error when an unbalanced transaction is specified in credit journal' do
      data = "@account_code: ck.hsbc\n@date_prefix: 2018-05-\n@debit_or_credit: credit\n01  100.00  ship.exp  10.00\n"
      create_bad_journal = -> { Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data) }
      expect { create_bad_journal.() }.to raise_error(TransactionNotBalancedError) do |error|
        expect(error.discrepancy).to eq(90.0)
      end
    end


    it 'inherits the debit/credit state of the main account when not specified in the journal' do
      data = "@account_code: ck.hsbc\n2018-05-01  100.00  ship.exp  100.00\n"
      journal = Journal.from_string(FN_CHART_OF_ACCOUNTS.(), data)
      expect(journal.debit_or_credit).to eq(:debit)
    end
  end
end
