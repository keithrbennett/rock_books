module RockBooks
module BsIsReportHelper


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


  def generate_report
    ERB.new(erb_report_template, 0, '-').result(binding)
  end

  alias_method :to_s, :generate_report
  alias_method :call, :generate_report

end
end
