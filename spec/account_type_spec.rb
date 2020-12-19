require_relative '../lib/rock_books/types/account_type'

module RockBooks

  RSpec.describe RockBooks::AccountType do

    it 'returns a proper account with the right key' do
      expect(AccountType.letter_to_type('A')). to eq(AccountType::ASSET)
      expect(AccountType.letter_to_type('Liability')). to eq(AccountType::LIABILITY)
      expect(AccountType.letter_to_type('EXP')). to eq(AccountType::EXPENSE)
      expect { AccountType.letter_to_type('nonexistent type') }.to raise_error(Error)
    end
  end
end


