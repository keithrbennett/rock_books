module RockBooks

RSpec.describe RockBooks::ChartOfAccounts do

  it "can be instantiated" do
    expect(ChartOfAccounts.new('')).not_to be nil
  end

  it 'can read its title' do
    data = '@title: My Chart of Accounts'
    expect(ChartOfAccounts.new(data).title).to eq('My Chart of Accounts')
  end

  it 'correctly handles doc_type' do
    data = "@doc_type: chart_of_accounts\n101 Cash in Bank"
    expect(ChartOfAccounts.new(data).doc_type).to eq('chart_of_accounts')
  end

  it 'can read an account code and name' do
    data = '101 D My Bank Checking Account'
    expect(ChartOfAccounts.new(data).accounts).to eq([ChartOfAccounts::Account.new('101', :debit, 'My Bank Checking Account')])
  end

  it 'can produce a report string' do
    data = "@title: Title\n101 D Cash in Bank\n"
    report_string = ChartOfAccounts.new(data).report_string
    expect(report_string).to include('Title')
    expect(report_string).to include('101')
    expect(report_string).to include('Cash in Bank')
  end

  it 'can look up a name by an id' do
    data = "101 D Cash in Bank\n201 C Loan Payable\n301 C Retained Earnings"
    expect(ChartOfAccounts.new(data).name_for_id('201')).to eq('Loan Payable')
  end

  it 'does not choke on empty or comment lines' do
    data = "101 D Cash in Bank\n\n\n\n201 C Loan Payable\n301 C Retained Earnings\n#\n#\n"
    ChartOfAccounts.new(data)
  end

  it 'can handle a final line without a line ending' do
    data = "101 D Cash in Bank\n201 C Loan Payable\n301 C Retained Earnings"
    expect(ChartOfAccounts.new(data).name_for_id('301')).to eq('Retained Earnings')
  end

  it 'correctly determines the debit/credit flag of the account' do
    data = "101 D Cash in Bank\n201 C Loan Payable\n301 C Retained Earnings"
    chart = ChartOfAccounts.new(data)
    expect(chart.debit_or_credit_for_id('101')).to eq(:debit)
    expect(chart.debit_or_credit_for_id('201')).to eq(:credit)
    expect(chart.debit_or_credit_for_id('301')).to eq(:credit)
  end

  it 'correctly determines whether or not an account id is included' do
    data = "101 D Cash in Bank\n"
    chart = ChartOfAccounts.new(data)
    expect(chart.include?('101')).to eq(true)
    expect(chart.include?('aaa')).to eq(false)
  end

end
end
