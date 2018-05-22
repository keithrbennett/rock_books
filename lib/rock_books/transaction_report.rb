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


  # Formats an entry like this, with entry description added on additional line(s) if it exists:
  # 2018-05-21   $120.00   701  Office Supplies
  def format_entry_no_split(entry)
    acct_amounts = entry.acct_amounts
    total_amount = acct_amounts.first.amount

    output = [
        entry.date.to_s,
        format_amount(total_amount),
        format_acct_amount(acct_amounts[1]),
        chart_of_accounts.name_for_code(acct_amounts[1].code)
    ].join('   ') << "\n"

    if entry.description && entry.description.length > 0
      output << entry.description
    end
    output
  end


  # Formats an entry like this, with entry description added on additional line(s) if it exists::
  # 2018-05-21   $120.00   95.00     701  Office Supplies
  #                        25.00     751  Gift to Customer
  def format_entry_with_split(entry)
    acct_amounts = entry.acct_amounts

    output = entry.date.to_s + '  '
    indent = ' ' * output.length
    output << format_acct_amount(acct_amounts.first) << "\n"

    acct_amounts[1..-1].each do |acct_amount|
      output << indent << format_acct_amount(acct_amount) << "\n"
    end

    if entry.description && entry.description.length > 0
      output << entry.description
    end
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