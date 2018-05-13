module PrimordialBooks

RSpec.describe PrimordialBooks::ChartOfAccounts do

  it "can be instantiated" do
    expect(ChartOfAccounts.new('')).not_to be nil
  end

  it 'can read its title' do
    data = '@title: My Chart of Accounts'
    expect(ChartOfAccounts.new(data).title).to eq('My Chart of Accounts')
  end

  it 'can read its date prefix' do
    data = '@date_prefix: 2018-'
    expect(ChartOfAccounts.new(data).date_prefix).to eq('2018-')
  end

  it 'can read an account code and name' do
    data = '101 My Bank Checking Account'
    expect(ChartOfAccounts.new(data).accounts).to eq([ChartOfAccounts::Account.new('101', 'My Bank Checking Account')])
  end
end



end
