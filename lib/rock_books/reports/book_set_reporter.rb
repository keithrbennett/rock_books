require_relative '../documents/book_set'

require_relative 'balance_sheet'
require_relative 'data/bs_is_data'
require_relative 'income_statement'
require_relative 'multidoc_txn_report'
require_relative 'receipts_report'
require_relative 'report_context'
require_relative 'journal_report'
require_relative 'multidoc_txn_by_account_report'
require_relative 'tx_one_account'
require_relative 'helpers/erb_helper'
require_relative 'helpers/reporter'

require 'prawn'

module RockBooks
class BookSetReporter

  extend Forwardable

  attr_reader :book_set, :output_dir, :filter, :context

  def_delegator :book_set, :all_entries
  def_delegator :book_set, :journals
  def_delegator :book_set, :chart_of_accounts
  def_delegator :book_set, :run_options

  FONT_FILESPEC = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'assets', 'fonts', 'JetBrainsMono-Medium.ttf'))


  def initialize(book_set, output_dir, filter = nil)
    @book_set = book_set
    @output_dir = output_dir
    @filter = filter
    @context = ReportContext.new(book_set.chart_of_accounts, book_set.journals, 80)
  end


  def generate
    check_prequisite_executables
    create_directories
    create_index_html

    do_statements
    do_journals
    do_transaction_reports
    do_single_account_reports
    do_receipts_report
  end


  # All methods after this point are private.

  private def do_statements
    bs_is_data = BsIsData.new(context)

    bal_sheet_text_report = BalanceSheet.new(context, bs_is_data.bal_sheet_data).generate
    write_report(:balance_sheet, bal_sheet_text_report)

    inc_stat_text_report = IncomeStatement.new(context, bs_is_data.inc_stat_data).generate
    write_report(:income_statement, inc_stat_text_report)
  end


  private def do_journals
    journals.each do |journal|
      report_data = JournalData.new(journal, context, filter).fetch
      text_report = JournalReport.new(report_data, context, filter).generate
      write_report(journal.short_name, text_report)
    end
  end


  private def do_transaction_reports

    do_date_or_amount_report = ->(sort_field, short_name) do
      data = MultidocTxnReportData.new(context, sort_field, filter).fetch
      text_report = MultidocTransactionReport.new(data, context).generate
      write_report(short_name, text_report)
    end

    do_acct_report = -> do
      data = MultidocTxnByAccountData.new(context).fetch
      text_report = MultidocTransactionByAccountReport.new(data, context).generate
      write_report(:all_txns_by_acct, text_report)
    end

    do_date_or_amount_report.(:date,   :all_txns_by_date)
    do_date_or_amount_report.(:amount, :all_txns_by_amount)
    do_acct_report.()
  end


  private def do_single_account_reports
    chart_of_accounts.accounts.each do |account|
      short_name = ('acct_' + account.code).to_sym
      data = TxOneAccountData.new(context, account.code).fetch
      text_report = TxOneAccount.new(data, context).generate
      write_report(short_name, text_report)
    end
  end


  private def do_receipts_report
    text_report = ReceiptsReport.new(context, *missing_existing_unused_receipts).generate
    write_report(:receipts, text_report)
  end


  private def run_command(command)
    puts "\n----\nRunning command: #{command}"
    stdout, stderr, status = Open3.capture3(command)
    puts "Exit code was #{status.exitstatus}."
    puts "\nStdout was:\n\n#{stdout}" unless stdout.size == 0
    puts "\nStderr was:\n\n#{stderr}" unless stderr.size == 0
    puts
  end


  private def check_prequisite_executables

    executable_exists = ->(name) do
      `which #{name}`
      $?.success?
    end

    raise "Report generation is not currently supported in Windows." if OS.windows?
    required_exes = OS.mac? ? %w(textutil) : %w(txt2html)
    missing_exes = required_exes.reject { |exe| executable_exists.(exe) }
    if missing_exes.any?
      raise "Missing required report generation executable(s): #{missing_exes.join(', ')}. Please install them with your system's package manager."
    end
  end


  private def create_directories
    %w(txt pdf html).each do |format|
      dir = File.join(output_dir, format, SINGLE_ACCT_SUBDIR)
      FileUtils.mkdir_p(dir)
    end
  end


  # "./pdf/short_name.pdf" or "./pdf/single_account/short_name.pdf"
  private def build_filespec(directory, short_name, file_format)
    fragments = [directory, file_format, "#{short_name}.#{file_format}"]
    is_acct_report = /^acct_/.match(short_name)
    if is_acct_report
      fragments.insert(2, SINGLE_ACCT_SUBDIR)
    end
    File.join(*fragments)
  end


  private def create_index_html
    filespec = build_filespec(output_dir, 'index', 'html')
    File.write(filespec, index_html_content)
    puts "Created index.html"
  end


  private def prawn_create_document(pdf_filespec, text)
    Prawn::Document.generate(pdf_filespec) do
      font(FONT_FILESPEC, size: 10)

      utf8_nonbreaking_space = "\uC2A0"
      unicode_nonbreaking_space = "\u00A0"
      text(text.gsub(' ', unicode_nonbreaking_space))
    end
    puts "Finished generating #{pdf_filespec} with prawn."
  end


  private def write_report(short_name, text_report)

    txt_filespec = build_filespec(output_dir, short_name, 'txt')
    html_filespec = build_filespec(output_dir, short_name, 'html')
    pdf_filespec = build_filespec(output_dir, short_name, 'pdf')

    File.write(txt_filespec, text_report)

    # Mac OS
    textutil = ->(font_size) do
      run_command("textutil -convert html -font 'Courier New Bold' -fontsize #{font_size} #{txt_filespec} -output #{html_filespec}")
    end

    # Linux
    txt2html = -> do
      command = [
          'txt2html',
          '--preformat_trigger_lines 0',
          '--hrule_min 9999 ',
          '--no-make_links',
          '--explicit_headings',
          "--outfile #{html_filespec}",
          txt_filespec
      ].join(' ')
      run_command(command)
    end

    prawn_create_document(pdf_filespec, text_report)
    if OS.mac?
      textutil.(14)
    else
      txt2html.()
    end

    hyperlinkized_text, replacements_made = HtmlHelper.convert_receipts_to_hyperlinks(File.read(html_filespec))
    if replacements_made
      File.write(html_filespec, hyperlinkized_text)
    end

    puts "Created reports in txt, html, and pdf for #{"%-20s" % short_name} at #{File.dirname(txt_filespec)}.\n\n\n"
  end


  private def missing_existing_unused_receipts
    missing_receipts = []
    existing_receipts = []
    receipt_full_filespec = ->(receipt_filespec) { File.join(run_options.receipt_dir, receipt_filespec) }

    # We will start out putting all filespecs in the unused array, and delete them as they are found in the transactions.
    unused_receipt_filespecs = Dir['receipts/**/*'].select { |s| File.file?(s) } \
        .sort \
        .map { |s| "./" +  s }  # Prepend './' to match the data

    all_entries.each do |entry|
      entry.receipts.each do |receipt|
        filespec = receipt_full_filespec.(receipt)
        unused_receipt_filespecs.delete(filespec)
        file_exists = File.file?(filespec)
        list = (file_exists ? existing_receipts : missing_receipts)
        list << { receipt: receipt, journal: entry.doc_short_name }
      end
    end
    [missing_receipts, existing_receipts, unused_receipt_filespecs]
  end


  private def index_html_content
    erb_filespec = File.join(File.dirname(__FILE__), 'templates', 'html', 'index.html.erb')
    erb = ERB.new(File.read(erb_filespec))
    erb.result_with_hash(
        journals: journals,
        chart_of_accounts: chart_of_accounts,
        run_options: run_options)
  end
end
end
