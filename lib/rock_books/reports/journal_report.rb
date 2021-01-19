require_relative 'data/journal_data'
require_relative 'helpers/erb_helper'
require_relative 'helpers/text_report_helper'

module RockBooks

class JournalReport

  include TextReportHelper
  include ErbHelper

  attr_accessor :context, :report_data


  def initialize(report_data, report_context, filter = nil)
    @report_data = report_data
    @context = report_context
  end


  def generate
    presentation_context = template_presentation_context.merge(fn_format_entry: method(:format_entry))
    ErbHelper.render_hashes('text/journal.txt.erb', report_data, presentation_context)
  end


  private def format_date_and_account_amount(date, acct_amount)
    "#{date}  #{format_acct_amount(acct_amount)}\n"
  end


  private def format_entry_first_acct_amount(entry)
    format_date_and_account_amount(entry.date, entry.acct_amounts.first)
  end


  private def format_entry_last_acct_amount(entry)
    format_date_and_account_amount(entry.date, entry.acct_amounts.last)
  end


  # Formats an entry like this, with entry description added on additional line(s) if it exists:
  # 2018-05-21   $120.00   701  Office Supplies
  private def format_entry_no_split(entry)
    output = format_entry_last_acct_amount(entry)

    if entry.description && entry.description.length > 0
      output += entry.description
    end
    output
  end


  # Formats an entry like this, with entry description added on additional line(s) if it exists::
  # 2018-05-21   $120.00   95.00     701  Office Supplies
  #                        25.00     751  Gift to Customer
  private def format_entry_with_split(entry)
    output = StringIO.new
    output << format_entry_first_acct_amount(entry)
    indent = ' ' * 12

    entry.acct_amounts[1..-1].each do |acct_amount|
      output << indent << format_acct_amount(acct_amount) << "\n"
    end

    if entry.description && entry.description.length > 0
      output << entry.description
    end

    output.string
  end


  private def format_entry(entry)
    if entry.acct_amounts.size > 2
      format_entry_with_split(entry)
    else
      format_entry_no_split(entry)
    end
  end
end
end