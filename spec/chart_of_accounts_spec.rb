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

  it 'can produce a report string' do
    data = "@title: Title\n101 Cash in Bank\n"
    report_string = ChartOfAccounts.new(data).report_string
    expect(report_string).to include('Title')
    expect(report_string).to include('101')
    expect(report_string).to include('Cash in Bank')
  end

  it 'can look up a name by an id' do
    data = "101 Cash in Bank\n201 Loan Payable\n301 Retained Earnings"
    expect(ChartOfAccounts.new(data).name_for_id('201')).to eq('Loan Payable')
  end
end
end
