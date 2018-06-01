require_relative 'reporter'
require_relative 'report_context'

module RockBooks

class TransactionReport

  include Reporter

  attr_accessor :journal, :context


  def initialize(journal, report_context)
    @journal = journal
    @context = report_context
  end


  def generate_header
    lines = [banner_line]
    lines << center(context.entity_name) if context.entity_name
    lines << center(journal.title)
    lines << banner_line
    lines << ''
    lines << ''
    lines << ''
    lines.join("\n")
  end


  def format_entry_first_acct_amount(entry)
    entry.date.to_s \
        << '  ' \
        << format_acct_amount(entry.acct_amounts.first) \
        << "\n"
  end


  # Formats an entry like this, with entry description added on additional line(s) if it exists:
  # 2018-05-21   $120.00   701  Office Supplies
  def format_entry_no_split(entry)
    output = format_entry_first_acct_amount(entry)

    if entry.description && entry.description.length > 0
      output << entry.description
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


  def generate_report(filter = nil)
    sio = StringIO.new
    sio << generate_header

    entries = journal.entries
    if filter
      entries = entries.select { |entry| filter.(entry) }
    end

    entries.each { |entry| sio << format_entry(entry) << "\n" }
    totals = AcctAmount.aggregate_amounts_by_account(JournalEntry.entries_acct_amounts(entries))
    sio << generate_and_format_totals('Totals', totals, context.chart_of_accounts)
    sio.string
  end


  alias_method :to_s, :generate_report
  alias_method :call, :generate_report
end

end