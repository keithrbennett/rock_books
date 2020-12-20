require_relative '../documents/chart_of_accounts'
require_relative '../documents/journal'
require_relative 'helpers/reporter'
require_relative 'report_context'

module RockBooks

class TxByAccount

  include Reporter

  attr_accessor :context


  def initialize(report_context)
    @context = report_context
  end


  def generate_header
    lines = [banner_line]
    lines << center(context.entity || 'Unspecified Entity')
    lines << center("Transactions by Account")
    lines << banner_line
    lines << ''
    lines << ''
    lines << ''
    lines.join("\n")
  end


  def account_header(account, account_total)
    total_string = "%.2f" % account_total
    title =  "Total: #{total_string} -- #{account_code_name_type_string(account)}"

    <<~HEREDOC
    #{banner_line}
    #{center(title)}
    #{banner_line}

    HEREDOC
  end


  def account_total_line(account_code, account_total)
    account_name = context.chart_of_accounts.name_for_code(account_code)
    "%.2f  Total for account: %s - %s" % [account_total, account_code, account_name]
  end


  def generate
    output = generate_header

    all_entries = Journal.entries_in_documents(context.journals)

    context.chart_of_accounts.accounts.each do |account|
      code = account.code
      account_entries = JournalEntry.entries_containing_account_code(all_entries, code)
      account_total = JournalEntry.total_for_code(account_entries, code)
      output << account_header(account, account_total)

      account_entries.each do |entry|
        output << format_multidoc_entry(entry) << "\n"
        output << "\n" if entry.description && entry.description.length > 0
      end
      output << account_total_line(code, account_total) << "\n"
      output  << "\n\n\n"
    end

    totals = AcctAmount.aggregate_amounts_by_account(JournalEntry.entries_acct_amounts(all_entries))
    output << generate_and_format_totals('Totals', totals)

    output
  end
end
end
