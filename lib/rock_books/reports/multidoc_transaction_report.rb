require_relative 'reporter'

module RockBooks

class MultidocTransactionReport < Struct.new(:chart_of_accounts, :documents, :page_width)

  include Reporter


  def format_header
    lines = [banner_line, center('Multi Document Transaction Report'), center('Source Documents:'), '']
    documents.each do |document|
      short_name = SHORT_NAME_FORMAT_STRING % document.short_name
      lines << center("#{short_name} -- #{document.title}")
    end
    lines << banner_line
    lines << ''
    lines << '   Date     Document           Amount      Account'
    lines << '   ----     --------           ------      -------'
    lines.join("\n") << "\n\n"
  end


  def format_entry(entry)
    acct_amounts = entry.acct_amounts

    output = entry.date.to_s << '  ' << (SHORT_NAME_FORMAT_STRING % entry.doc_short_name) # "2017-10-29  hsbc_visa"
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



  def generate_report(filter = nil)
    self.page_width ||= 80

    entries = Reporter.entries_in_documents(documents)

    if filter
      entries = entries.select { |entry| filter.(entry) }
    end

    sio = StringIO.new
    sio << format_header
    entries.each { |entry| sio << format_entry(entry) << "\n" }

    totals = AcctAmount.aggregate_amounts_by_account(JournalEntry.entries_acct_amounts(entries))
    sio << generate_and_format_totals('Totals', totals, chart_of_accounts)

    sio << "\n"
    sio.string
  end


  alias_method :to_s, :generate_report
  alias_method :call, :generate_report
end
end
