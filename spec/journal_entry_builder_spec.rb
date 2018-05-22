require_relative '../lib/rock_books/journal_entry_builder'
require_relative 'samples'

module RockBooks

  RSpec.describe RockBooks::JournalEntryBuilder do

    create_empty_journal = -> do
      Journal.new(Samples.chart_of_accounts, "@account_code: 101\n@debit_or_credit: debit")
    end
    TEST_DATE = Date.iso8601('2018-05-13')


    it 'parses account tokens correctly with only account number' do

      expected = [
          AcctAmount.new(TEST_DATE, '101', -7.89),
          AcctAmount.new(TEST_DATE, '701', 7.89)
      ]
      data_line = "#{TEST_DATE}  7.89  701"
      builder = JournalEntryBuilder.new(data_line, create_empty_journal.())
      actual = builder.build

      expect(actual.acct_amounts[0]).to eq(expected[0])
      expect(actual.acct_amounts[1]).to eq(expected[1])
      expect(actual.acct_amounts).to eq(expected)
    end


    it 'parses account tokens correctly with pairs' do
      expected = [
          AcctAmount.new(TEST_DATE, '101', -3.75),
          AcctAmount.new(TEST_DATE, '701', 1.25),
          AcctAmount.new(TEST_DATE, '702', 2.50)
      ]
      data_line = "#{TEST_DATE}  3.75  701  1.25  702  2.50"
      builder = JournalEntryBuilder.new(data_line, create_empty_journal.())
      actual = builder.build.acct_amounts

      expect(actual).to eq(expected)
    end


    it 'raises an error when an even number of tokens greater than 0 is passed' do
      data_line = "#{TEST_DATE}  7.89  701  7.89  702"
      builder = JournalEntryBuilder.new(data_line, create_empty_journal.())
      expect { builder.build.acct_amounts }.to raise_error(Error)
    end


    it 'parses a general journal' do
      gj_filespec = File.join(File.dirname(__FILE__), 'samples', 'general_journal.rdt')
      general_journal = Journal.new(Samples.chart_of_accounts, File.read(gj_filespec))
      acct_amounts = general_journal.entries.first.acct_amounts
      expect(acct_amounts.map(&:code)).to eq(%w(101  141  142  201  301))
      expect(acct_amounts.map(&:amount)).to eq([1000.00, 2500.00, -500.00, -800.00, -2200.00])
    end
  end

end
