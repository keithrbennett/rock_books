require_relative 'helpers/bs_is_report_helper'
require_relative 'data/income_statement_data'
require_relative '../documents/journal'
require_relative 'report_context'

module RockBooks


  class IncomeStatement

  include Reporter
  include BsIsReportHelper

  attr_accessor :context, :data


  def initialize(report_context)
    @context = report_context
    @data = IncomeStatementData.new(context).call
  end


  def erb_report_template
    <<~HEREDOC
<%= banner_line %>
<%= center(context.entity || 'Unspecified Entity') %>
<%= center('Income Statement -- #{start_date} to #{end_date}') %>
<%= banner_line %>

<% %i(income expense).each do |section_type| -%>
<%= section_heading(section_type) %>

<% section_data = data[section_type] -%>
<% section_data[:acct_totals].each do |code, amount| -%>
<%= line_item_format_string % [amount, code, acct_name(code)] %>
<% end -%>
------------
<%= sprintf(line_item_format_string, section_data[:total], '', '') %>
<% end %>


Net Income

<%= sprintf(line_item_format_string, data[:net_income], '', '') %>
============
    HEREDOC
  end

end
end
