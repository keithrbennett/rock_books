require_relative 'reporter'

module RockBooks

class MultidocTransactionReport < Struct.new(:documents, :chart_of_accounts, :page_width)

  include Reporter

  class LineItem < Struct.new(:document_short_name, :entry); end


  def collate_entries

    line_items = []
    documents.each do |document|
      document.entries.each do |entry|
        puts "entry should be a JournalEntry but is a #{entry.class}" unless entry.is_a?(JournalEntry)
        line_items << LineItem.new(document.short_name, entry)
      end
    end
    line_items = line_items.sort_by! { |line_item| line_item.entry.date }
    line_items
  end


  def format_header
    lines = [banner_line, center('Multi Document Transaction Report'), center('Source Documents:'), '']
    documents.each do |document|
      short_name = "%12.12s" % document.short_name
      lines << center("#{short_name} -- #{document.title}")
    end
    lines << banner_line
    lines << ''
    lines << '   Date     Document           Amount      Account'
    lines << '   ----     --------           ------      -------'
    lines.join("\n") << "\n\n"
  end


  def format_acct_amount(acct_amount)
    "%s  %s  %s" % [
        format_amount(acct_amount.amount),
        format_account_code(acct_amount.code),
        chart_of_accounts.name_for_code(acct_amount.code)
    ]
  end


  # Formats an entry like this, with entry description added on additional line(s) if it exists:
  # 2018-05-21   $120.00   701  Office Supplies
  def format_line_item_no_split(entry, document_short_name)
    acct_amounts = entry.acct_amounts
    total_amount = acct_amounts.first.amount

    output = [
        entry.date.to_s,
        "%-12s" % document_short_name,
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
  def format_line_item(line_item)
    entry = line_item.entry
    acct_amounts = entry.acct_amounts

    output = entry.date.to_s << '  ' << ("%-16s" % line_item.document_short_name)
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


  def generate_report
    data = collate_entries
    sio = StringIO.new
    sio << format_header
    data.each { |line_item| sio << format_line_item(line_item) << "\n" }
    sio.string
  end


  alias_method :to_s, :generate_report
  alias_method :call, :generate_report
end
end
