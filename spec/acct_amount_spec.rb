require_relative '../lib/primordial_books/journal'

module PrimordialBooks

  RSpec.describe PrimordialBooks::AcctAmount do

    test_date = -> { Date.iso8601('2018-05-13')}

    it 'parses account tokens correctly with only account number' do
      expected = [AcctAmount.new(test_date, '909', 7.89)]
      expect(AcctAmount.parse_tokens(test_date, ['909'], 7.89)).to eq(expected)
    end

    it 'parses account tokens correctly with pairs' do
      expected = [AcctAmount.new(test_date, '888', 8.88), AcctAmount.new(test_date, '999', 9.99)]
      expect(AcctAmount.parse_tokens(test_date, ['888', 8.88, '999', 9.99], nil)).to eq(expected)
    end

    it 'raises an error when an odd number of tokens greater than 1 is passed' do
      expect { AcctAmount.parse_tokens(test_date, ['888', 8.88, '999'], nil) }.to raise_error(RuntimeError)
    end

  end
end
