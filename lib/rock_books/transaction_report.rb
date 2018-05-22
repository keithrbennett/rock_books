require_relative 'reporter'

module RockBooks

class TransactionReport < Struct.new(:document, :chart_of_accounts, :page_width)

  include Reporter


  def format_header

    lines = [banner_line, center(document.title)]
    if document.account_code
      lines << "Account: #{document.account_code} -- #{chart_of_accounts.name_for_code(document.account_code)}"
    end
    lines << banner_line
    lines.join("\n") << "\n\n"
  end


  def format_entry(entry)
    if entry.acct_amounts.size > 2
      format_entry_with_split(entry)
    else
      format_entry_no_split(entry)
    end
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