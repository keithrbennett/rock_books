require_relative 'reporter'

module RockBooks

class TransactionReport < Struct.new(:document, :chart_of_accounts, :page_width)

  include Reporter


  def header
    subtitle = "Account: #{document.account_code} -- #{chart_of_accounts.name_for_id(document.account_code)}"

    <<~HEREDOC
    #{banner_line}
    #{center(document.title)}
    #{center(subtitle)}
    #{banner_line}

    HEREDOC
  end


  def entry(entry)
    <<~HEREDOC

    HEREDOC


  end

  def generate_report
    header
  end


  alias_method :to_s, :generate_report
  alias_method :call, :generate_report
end

end