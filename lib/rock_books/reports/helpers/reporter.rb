require_relative '../../documents/journal_entry'

module RockBooks
module Reporter

  SHORT_NAME_MAX_LENGTH = 16

  SHORT_NAME_FORMAT_STRING = "%#{SHORT_NAME_MAX_LENGTH}.#{SHORT_NAME_MAX_LENGTH}s"


  def page_width
    context.page_width || 80
  end


  def format_account_code(code)
    "%*.*s" % [max_account_code_length, max_account_code_length, code]
  end


  def account_code_name_type_string(account)
    "#{account.code} -- #{account.name}  (#{account.type.to_s.capitalize})"
  end


  def account_code_name_type_string_for_code(account_code)
    account = context.chart_of_accounts.account_for_code(account_code)
    raise "Account for code #{account_code} not found" unless account
    account_code_name_type_string(account)
  end


  def format_amount(amount)
    "%9.2f" % amount
  end


  # e.g. "    117.70     tr.mileage  Travel - Mileage Allowance"
  def format_acct_amount(acct_amount)
    "%s  %s  %s" % [
        format_amount(acct_amount.amount),
        format_account_code(acct_amount.code),
        context.chart_of_accounts.name_for_code(acct_amount.code)
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
    @max_account_code_length ||= context.chart_of_accounts.max_account_code_length
  end


  def total_with_ok_or_discrepancy(amount)
    status_message = (amount == 0.0)  ? '(Ok)' : '(Discrepancy)'
    sprintf(line_item_format_string, amount, status_message, '')
  end


  def generate_and_format_totals(section_caption, totals)
    totals_for_display = totals.keys.sort.map do |account_code|
      account_name = context.chart_of_accounts.name_for_code(account_code)
      account_total = totals[account_code]
      {
        amount: account_total,
        code: account_code,
        name: account_name
      }
    end


    output = section_caption
    output << "\n#{'-' * section_caption.length}\n\n"
    format_string = "%12.2f   %-#{context.chart_of_accounts.max_account_code_length}s   %s\n"
    totals_for_display.each do |total|
      output << format_string % [total[:amount], total[:code], total[:name]]
    end

    output << "------------\n"
    output << "%12.2f\n" % totals.values.sum.round(2)
    output
  end


  def generate_account_type_section(section_caption, totals, section_type, need_to_reverse_sign)
    account_codes_this_section = context.chart_of_accounts.account_codes_of_type(section_type)

    totals_this_section = totals.select do |account_code, _amount|
      account_codes_this_section.include?(account_code)
    end

    if need_to_reverse_sign
      totals_this_section.each { |code, amount| totals_this_section[code] = -amount }
    end

    section_total_amount = totals_this_section.map { |aa| aa.last }.sum

    output = generate_and_format_totals(section_caption, totals_this_section)
    [ output, section_total_amount ]
  end


  def format_multidoc_entry(entry)
    acct_amounts = entry.acct_amounts

    # "2017-10-29  hsbc_visa":
    output = entry.date.to_s << '  ' << (SHORT_NAME_FORMAT_STRING % entry.doc_short_name) << '  '

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

  def read_template(filename)
    File.read(File.join(File.dirname(__FILE__), '..', 'templates', filename))
  end

  def line_item_format_string
    @line_item_format_string ||= "%12.2f   %-#{context.chart_of_accounts.max_account_code_length}s   %s"
  end


  # :asset => "Assets\n------"
  def section_heading(section_type)
    title = AccountType.symbol_to_type(section_type).plural_name
    "\n\n" + title + "\n" + ('-' * title.length)
  end


  def acct_name(code)
    context.chart_of_accounts.name_for_code(code)
  end


  def start_date
    context.chart_of_accounts.start_date
  end


  def end_date
    context.chart_of_accounts.end_date
  end


  def erb_template(erb_filename)
    erb_filespec = File.absolute_path(File.join(File.dirname(__FILE__), '..', 'templates', erb_filename))
    eoutvar = "@outvar_#{erb_filename.split('.').first}" # dots will be evaulated by `eval`, must remove them
    ERB.new(File.read(erb_filespec), eoutvar: eoutvar, trim_mode: '-')
  end


  def erb_render_binding(erb_filename, template_binding)
    puts "Rendering template #{erb_filename}..."
    erb_template(erb_filename).result(template_binding)
  end


  # Takes 2 hashes, one with data, and the other with presentation functions/lambdas, and passes their union to ERB
  # for rendering.
  def erb_render_hashes(erb_filename, data_hash, presentation_hash  )
    puts "Rendering template #{erb_filename}..."
    combined_hash = (data_hash || {}).merge(presentation_hash || {})
    erb_template(erb_filename).result_with_hash(combined_hash)
  end


  def template_presentation_context
    {
      banner_line: banner_line,
      end_date: end_date,
      entity: context.entity,
      fn_acct_name:  method(:acct_name),
      fn_account_code_name_type_string_for_code: method(:account_code_name_type_string_for_code),
      fn_center: method(:center),
      fn_erb_render_binding: method(:erb_render_binding),
      fn_format_multidoc_entry: method(:format_multidoc_entry),
      fn_generate_and_format_totals: method(:generate_and_format_totals),
      fn_section_heading: method(:section_heading),
      fn_total_with_ok_or_discrepancy: method(:total_with_ok_or_discrepancy),
      line_item_format_string: line_item_format_string,
      short_name_format_string: SHORT_NAME_FORMAT_STRING,
      start_date: start_date,
    }
  end
end
end


