require_relative 'reporter'

module RockBooks

class TransactionReport < Struct.new(:document, :chart_of_accounts, :page_width)

  include Reporter


  def initialize(document, chart_of_accounts, page_width)
    super
    @max_account_code_length = chart_of_accounts.max_account_code_length
  end


  def format_account_code(code)
    "%*.*s" % [@max_account_code_length, @max_account_code_length, code]
  end


  def format_amount(amount)
    "%9.2f" % amount
  end


  def format_acct_amount(acct_amount)
    "%s  %s" % [format_account_code(acct_amount.code), format_amount(acct_amount.amount)]
  end


  def format_header
    subtitle = "Account: #{document.account_code} -- #{chart_of_accounts.name_for_code(document.account_code)}"

    <<~HEREDOC
    #{banner_line}
    #{center(document.title)}
    #{center(subtitle)}
    #{banner_line}

    HEREDOC
  end


  def format_entry(entry)
    acct_amounts = entry.acct_amounts
    total_amount = acct_amounts.first.amount

    fragments = [
        entry.date.to_s,
        format_amount(total_amount),
        format_acct_amount(acct_amounts[1]),
        chart_of_accounts.name_for_code(acct_amounts[1].code)
    ]

    s = fragments.join('   ')
    if entry.description && entry.description.length > 0
      s << "\n" << entry.description
    end
    s
  end


  def generate_report
    sio = StringIO.new
    sio << format_header
    document.entries.each { |entry| sio << format_entry(entry) << "\n" }
    sio.string
  end


  alias_method :to_s, :generate_report
  alias_method :call, :generate_report
end

end