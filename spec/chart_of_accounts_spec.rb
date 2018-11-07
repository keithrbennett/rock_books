require_relative '../lib/rock_books/documents/chart_of_accounts'
require_relative '../lib/rock_books/types/account'

module RockBooks

RSpec.describe RockBooks::ChartOfAccounts do

  it "can be instantiated" do
    expect(ChartOfAccounts.new([])).not_to be nil
  end

  it "can be instantiated with a string" do
    expect(ChartOfAccounts.from_string('')).not_to be nil
  end

  it 'can read its title' do
    data = '@title: My Chart of Accounts'
    expect(ChartOfAccounts.from_string(data).title).to eq('My Chart of Accounts')
  end

  it 'correctly handles doc_type' do
    data = "@doc_type: chart_of_accounts\n101 A Cash in Bank"
    expect(ChartOfAccounts.from_string(data).doc_type).to eq('chart_of_accounts')
  end

  it 'can read an account code and name' do
    data = '101 A My Bank Checking Account'
    expect(ChartOfAccounts.from_string(data).accounts).to eq([Account.new('101', :asset, 'My Bank Checking Account')])
  end

  it 'can produce a report string' do
    data = "@title: Title\n101 A Cash in Bank\n"
    report_string = ChartOfAccounts.from_string(data).report_string
    expect(report_string).to include('Title')
    expect(report_string).to include('101')
    expect(report_string).to include('Cash in Bank')
  end

  it 'can look up a name by a code' do
    data = "101 A Cash in Bank\n201 L Loan Payable\n301 O Retained Earnings"
    expect(ChartOfAccounts.from_string(data).name_for_code('201')).to eq('Loan Payable')
  end

  it 'does not choke on empty or comment lines' do
    data = "101 A Cash in Bank\n\n\n\n201 L Loan Payable\n301 O Retained Earnings\n#\n#\n"
    ChartOfAccounts.from_string(data)
  end

  it 'can handle a final line without a line ending' do
    data = "101 A Cash in Bank\n201 L Loan Payable\n301 O Retained Earnings"
    expect(ChartOfAccounts.from_string(data).name_for_code('301')).to eq('Retained Earnings')
  end

  it 'correctly determines the account type of the account' do
    data = "101 A Cash in Bank\n201 L Loan Payable\n301 O Retained Earnings"
    chart = ChartOfAccounts.from_string(data)
    expect(chart.type_for_code('101')).to eq(:asset)
    expect(chart.type_for_code('201')).to eq(:liability)
    expect(chart.type_for_code('301')).to eq(:equity)
  end

  it 'correctly determines whether or not an account code is included' do
    data = "101 A Cash in Bank\n201 L Loan Payable\n301 O Retained Earnings"
    chart = ChartOfAccounts.from_string(data)
    expect(chart.include?('101')).to eq(true)
    expect(chart.include?('aaa')).to eq(false)
  end

end
end
