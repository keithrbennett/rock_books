require_relative '../documents/journal_entry'

module RockBooks
module Reporter

  module_function

  SHORT_NAME_MAX_LENGTH = 16

  SHORT_NAME_FORMAT_STRING = "%#{SHORT_NAME_MAX_LENGTH}.#{SHORT_NAME_MAX_LENGTH}s"

  def format_account_code(code)
    "%*.*s" % [max_account_code_length, max_account_code_length, code]
  end


  def format_amount(amount)
    "%9.2f" % amount
  end


  # e.g. "    117.70     tr.mileage  Travel - Mileage Allowance"
  def format_acct_amount(acct_amount)
    "%s  %s  %s" % [
        format_amount(acct_amount.amount),
        format_account_code(acct_amount.code),
        chart_of_accounts.name_for_code(acct_amount.code)
    ]
  end


  def banner_line
    @banner_line ||= '-' * page_width
  end


  def center(string)
    indent = (page_width - string.length) / 2
    indent = 0 if indent < 0
    (' ' * indent) + string
  end


  def max_account_code_length
    @max_account_code_length ||= chart_of_accounts.max_account_code_length
  end


  def generate_and_format_totals(section_caption, totals, chart_of_accounts)
    output = section_caption
    output << "\n#{'-' * section_caption.length}\n\n"
    format_string = "%12.2f   %-#{chart_of_accounts.max_account_code_length}s   %s\n"
    totals.keys.sort.each do |account_code|
      account_name = chart_of_accounts.name_for_code(account_code)
      account_total = totals[account_code]
      output << format_string % [account_total, account_code, account_name]
    end

    output << "------------\n"
    output << "%12.2f\n" % totals.values.sum.round(2)
    output
  end


  def generate_account_type_section(section_caption, totals, section_type, need_to_reverse_sign)
    account_codes_this_section = chart_of_accounts.account_codes_of_type(section_type)

    totals_this_section = totals.select do |account_code, _amount|
      account_codes_this_section.include?(account_code)
    end

    if need_to_reverse_sign
      totals_this_section.each { |code, amount| totals_this_section[code] = -amount }
    end

    section_total_amount = totals_this_section.map { |aa| aa.last }.sum

    output = generate_and_format_totals(section_caption, totals_this_section, chart_of_accounts)
    [ output, section_total_amount ]
  end


  # Returns the entries in the specified documents, sorted by date and document short name,
  # optionally filtered with the specified filter.
  def entries_in_documents(documents, filter = nil)
    entries = documents.each_with_object([]) do |document, entries|
      entries << document.entries
    end.flatten

    if filter
      entries = entries.select {|entry| filter.(entry) }
    end

    entries.sort_by do |entry|
      [entry.date, entry.doc_short_name]
    end
  end


  def acct_amounts_in_documents(documents, entries_filter = nil, acct_amounts_filter = nil)
    entries = entries_in_documents(documents, entries_filter)

    acct_amounts = entries.each_with_object([]) do |entry, acct_amounts|
      acct_amounts << entry.acct_amounts
    end.flatten

    if acct_amounts_filter
      acct_amounts.select! { |aa| acct_amounts_filter.(aa) }
    end

    acct_amounts
  end


  def format_multidoc_entry(entry)
    acct_amounts = entry.acct_amounts

    # "2017-10-29  hsbc_visa":
    output = entry.date.to_s << '  ' << (SHORT_NAME_FORMAT_STRING % entry.doc_short_name)

    indent = ' ' * output.length

    output << format_acct_amount(acct_amounts.first) << "\n"

    acct_amounts[1..-1].each do |acct_amount|
      output << indent << format_acct_amount(acct_amount) << "\n"
    end

    if entry.description && entry.description.length > 0
      output << entry.description
    end

    output
  end

end
end


