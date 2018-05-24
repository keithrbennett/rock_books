require_relative 'reporter'

module RockBooks

class TransactionReport < Struct.new(:chart_of_accounts, :document, :page_width)

  include Reporter


  def format_header
    <<~HEREDOC
    #{banner_line}
    #{center(document.title)}
    #{banner_line}


    HEREDOC
  end


  def format_acct_amount(acct_amount)
    "%s  %s  %s" % [
        format_account_code(acct_amount.code),
        format_amount(acct_amount.amount),
        chart_of_accounts.name_for_code(acct_amount.code)
    ]
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


  def generate_report(filter = nil)
    self.page_width ||= 80
    sio = StringIO.new
    sio << format_header

    entries = document.entries
    if filter
      entries = entries.select { |entry| filter.(entry) }
    end

    entries.each { |entry| sio << format_entry(entry) << "\n" }
    sio << generate_and_format_totals(JournalEntry.entries_acct_amounts(entries), chart_of_accounts)
    sio.string
  end


  alias_method :to_s, :generate_report
  alias_method :call, :generate_report
end

end