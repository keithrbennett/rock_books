require_relative '../documents/chart_of_accounts'
require_relative '../documents/journal'
require_relative 'reporter'
require_relative 'report_context'

module RockBooks

  class TxOneAccount

    include Reporter

    attr_reader :context, :account_code, :account


    def initialize(report_context, account_code)
      @context = report_context
      @account_code = account_code
      @account = context.chart_of_accounts.account_for_code(account_code)
    end


    def generate_header(account_total)
      lines = [banner_line]
      lines << center(context.entity_name) if context.entity_name
      lines << center("Transactions for Account #{account_code_name_type_string(account)}")
      lines << center("Total: %.2f" % account_total)
      lines << banner_line
      lines << ''
      lines << ''
      lines << ''
      lines.join("\n")
    end


    def process_account(entries, account)
      entries.each_with_object('') do |entry, output|
        output << format_multidoc_entry(entry) << "\n"
        output << "\n" if entry.description && entry.description.length > 0
      end
    end


    def generate_report
      entries = Journal.entries_in_documents(context.journals, JournalEntryFilters.account_code_filter(account_code))
      account_total = JournalEntry.total_for_code(entries, account_code)
      output = generate_header(account_total)
      output << process_account(entries, account)
      output
    end

    alias_method :to_s, :generate_report
    alias_method :call, :generate_report
  end

end
