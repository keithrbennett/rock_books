require_relative 'data/journal_data'
require_relative 'helpers/reporter'
require_relative 'report_context'

module RockBooks

class JournalReport

  include Reporter

  attr_accessor :context, :data, :title


  def initialize(journal, report_context, filter = nil)
    raise "Journal title not specified for journal #{journal}" unless journal.title
    @context = report_context
    @data = JournalData.new(journal, report_context, filter).call
    @title = journal.title
  end


  def format_entry_first_acct_amount(entry)
    entry.date.to_s \
         + '  ' \
         + format_acct_amount(entry.acct_amounts.last) \
         + "\n"
  end


  # Formats an entry like this, with entry description added on additional line(s) if it exists:
  # 2018-05-21   $120.00   701  Office Supplies
  def format_entry_no_split(entry)
    output = format_entry_first_acct_amount(entry)

    if entry.description && entry.description.length > 0
      output += entry.description
    end
    output
  end


  # Formats an entry like this, with entry description added on additional line(s) if it exists::
  # 2018-05-21   $120.00   95.00     701  Office Supplies
  #                        25.00     751  Gift to Customer
  def format_entry_with_split(entry)
    output = format_entry_first_acct_amount(entry)
    indent = ' ' * 12

    entry.acct_amounts[1..-1].each do |acct_amount|
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


  def erb_report_template
    read_template('journal.txt.erb')
  end
end
end