require_relative '../documents/journal'
require_relative 'reporter'

module RockBooks

class MultidocTransactionReport < Struct.new(:chart_of_accounts, :documents, :page_width)

  include Reporter


  def generate_header
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


  def generate_report(filter = nil)
    self.page_width ||= 80

    entries = Journal.entries_in_documents(documents, filter)

    sio = StringIO.new
    sio << generate_header
    entries.each { |entry| sio << format_multidoc_entry(entry) << "\n" }

    totals = AcctAmount.aggregate_amounts_by_account(JournalEntry.entries_acct_amounts(entries))
    sio << generate_and_format_totals('Totals', totals, chart_of_accounts)

    sio << "\n"
    sio.string
  end


  alias_method :to_s, :generate_report
  alias_method :call, :generate_report
end
end
