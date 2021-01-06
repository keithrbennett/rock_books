require_relative '../lib/rock_books/documents/chart_of_accounts'
require_relative '../lib/rock_books/types/account'

module RockBooks

RSpec.describe RockBooks::ChartOfAccounts do

  let(:sample_title) { "2019 Chart of Accounts" }
  let(:doc_type)     { "chart_of_accounts" }
  let(:entity)       { 'XYZ Corporation' }
  let(:start_date)   { '2019-01-01' }
  let(:end_date)     { '2019-12-31' }
  let(:sample_code)  { 'ck.knox' }
  let(:sample_type)  { 'A' }
  let(:sample_name)  { 'Checking Account - Knox Bank' }

  let(:sample_text) {
    <<~HEREDOC
      @title:       #{sample_title}
      @doc_type:    #{doc_type}
      @entity:      #{entity}
      @start_date:  #{start_date}
      @end_date:    #{end_date}

      #{sample_code}  #{sample_type}  #{sample_name}
    HEREDOC

  }

  let(:sample_chart) { ChartOfAccounts.from_string(sample_text) }

  it "can be instantiated with a string" do
    expect(sample_chart).to be_a(ChartOfAccounts)
  end

  it 'can read its title' do
    expect(sample_chart.title).to eq(sample_title)
  end

  it 'correctly handles doc_type' do
    expect(sample_chart.doc_type).to eq('chart_of_accounts')
  end

  it 'can read an account code and name' do
    expect(sample_chart.accounts).to eq([Account.new(sample_code, :asset, sample_name)])
  end

  it 'can produce a report string' do
    report_string = sample_chart.report_string
    expect(report_string).to include(sample_title)
    expect(report_string).to include(sample_code)
    expect(report_string).to include(sample_name)
  end

  it 'can look up a name by a code' do
    expect(sample_chart.name_for_code(sample_code)).to eq(sample_name)
  end

  it 'does not choke on empty or comment lines' do
    data = "#{sample_text}\n\n\n\n201 L Loan Payable\n301 O Retained Earnings\n#\n#\n"
    chart = ChartOfAccounts.from_string(data)
    expect(chart.accounts.size).to eq(3)  # sample text plus 2 specified here
  end

  it 'can handle a final line without a line ending' do
    expect(ChartOfAccounts.from_string(sample_text.chomp.chomp.chomp).name_for_code(sample_code)).to eq(sample_name)
  end

  it 'correctly determines the account type of the account' do
    expect(sample_chart.type_for_code(sample_code)).to eq(:asset)
  end

  it 'correctly determines whether or not an account code is included' do
    expect(sample_chart.include?(sample_code)).to eq(true)
    expect(sample_chart.include?('aaa')).to eq(false)
  end

end
end
