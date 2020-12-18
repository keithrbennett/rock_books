require_relative 'balance_sheet_data'
require_relative '../filters/journal_entry_filters'
require_relative '../documents/journal'
require_relative 'report_context'

module RockBooks

# Reports the balance sheet as of the specified date.
# Unlike other reports, we need to process transactions from the beginning of time
# in order to calculate the correct balances, so we ignore the global $filter.
class BalanceSheet

  include Reporter

  attr_accessor :context, :data


  def erb_report_template
    <<~HEREDOC
<%= banner_line %>
<%= center(context.entity || 'Unspecified Entity') %>
<%= center('Balance Sheet for Period Ending #{end_date}') %>
<%= banner_line %>

<% %i(asset liability equity).each do |section_type| -%>
<%= section_heading(section_type) %>
<% section_data = data[section_type] -%>
<% section_data[:acct_totals].each do |code, amount| -%>
<%= line_item_format_string % [amount, code, acct_name(code)] %>
<% end -%>
------------
<%= sprintf(line_item_format_string, section_data[:total], '', '') %>
<% end %>


Assets - (Liabilities + Equity) 

<% status_message = (data[:grand_total] == 0.0)  ? '(Ok)' : '(Discrepancy)' -%>
<%= sprintf(line_item_format_string, data[:grand_total], '', status_message) %>
============
    HEREDOC
  end


  def line_item_format_string
    @line_item_format_string ||= "%12.2f   %-#{context.chart_of_accounts.max_account_code_length}s   %s"
  end


  def initialize(report_context)
    @context = report_context
    @data = BalanceSheetData.new(context).call
  end


  # :asset => "Assets\n------"
  def section_heading(section_type)
    title = { asset: 'Assets', liability: 'Liabilities', equity: 'Equity' }[section_type]
    "\n\n" + title + "\n" + ('-' * title.length)
  end


  def acct_name(code)
    context.chart_of_accounts.name_for_code(code)
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
