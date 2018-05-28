require_relative '../lib/rock_books/account_type'

module RockBooks

  RSpec.describe RockBooks::AccountType do

    it 'returns a proper account with the right key' do
      expect(AccountType.to_type('A')). to eq(AccountType::ASSET)
      expect(AccountType.to_type('Liability')). to eq(AccountType::LIABILITY)
      expect(AccountType.to_type('EXP')). to eq(AccountType::EXPENSE)
      expect { AccountType.to_type('nonexistent type') }.to raise_error(Error)
    end
  end
end


