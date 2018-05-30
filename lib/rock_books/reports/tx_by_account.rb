require_relative '../documents/chart_of_accounts'
require_relative 'reporter'

module RockBooks

class TxByAccount < Struct.new(:chart_of_accounts, :journals, :page_width)

  include Reporter

  def initialize(chart_of_accounts, journals, page_width = 80)
    super
  end

  def generate_header
    <<~HEREDOC
    #{banner_line}
    #{center("Transactions by Account")}
    #{banner_line}

    HEREDOC
  end


  def account_header(account)
    "Account:  #{account.code} -- #{account.name}  (#{account.type.to_s.capitalize})\n"
  end


  def generate_report
    output = generate_header

    all_entries = Reporter.entries_in_documents(journals)

    chart_of_accounts.accounts.each do |account|
      code = account.code
      output << account_header(account)
      account_entries = all_entries.select { |entry| entry.contains_account?(code) }
      account_entries.each { |entry| output << format_multidoc_entry(entry) }
    end

    output
  end

  alias_method :to_s, :generate_report
  alias_method :call, :generate_report


end

end
