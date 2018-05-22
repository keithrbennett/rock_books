module RockBooks
module Reporter

  module_function

  def format_account_code(code)
    "%*.*s" % [max_account_code_length, max_account_code_length, code]
  end


  def format_amount(amount)
    "%9.2f" % amount
  end


  def format_acct_amount(acct_amount)
    "%s  %s" % [format_account_code(acct_amount.code), format_amount(acct_amount.amount)]
  end


  def banner_line
    @banner_line ||= '-' * page_width
  end


  def center(string)
    (' ' * ((page_width - string.length) / 2)) + string
  end


  def max_account_code_length
    @max_account_code_length ||= chart_of_accounts.max_account_code_length
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
end
end

