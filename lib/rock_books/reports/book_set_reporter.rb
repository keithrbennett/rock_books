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


module RockBooks
class BookSetReporter

  extend Forwardable

  attr_reader :book_set, :output_dir, :filter, :context

  def_delegator :book_set, :all_entries
  def_delegator :book_set, :journals
  def_delegator :book_set, :chart_of_accounts
  def_delegator :book_set, :run_options


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
    all_reports(filter).each { |report| write_report(report) }
  end


  # All methods after this point are private.

  private def do_report(short_name, text_report)
    txt_filespec = build_filespec(output_dir, short_name, 'txt')
    File.write(txt_filespec, text_report)
  end


  private def do_statements
    bs_is_data = BsIsData.new(context)

    bal_sheet_text_report = BalanceSheet.new(context, bs_is_data.bal_sheet_data).generate
    do_report(:balance_sheet, bal_sheet_text_report)

    inc_stat_text_report = IncomeStatement.new(context, bs_is_data.inc_stat_data).generate
    do_report(:income_statement, inc_stat_text_report)
  end


  private def do_journals
    journals.each do |journal|
      report_data = JournalData.new(journal, context, filter).fetch
      report_text = JournalReport.new(report_data, context, filter).generate
      do_report(journal.short_name, report_text)
    end
  end

  # @return a hash whose keys are short names as symbols, and values are report text strings
  private def all_reports(filter = nil)

    reports_by_short_name = {}

    do_transaction_reports = -> do
      reports_by_short_name[:all_txns_by_date]   = MultidocTransactionReport.new(context, :date, filter).generate
      reports_by_short_name[:all_txns_by_amount] = MultidocTransactionReport.new(context, :amount, filter).generate
      reports_by_short_name[:all_txns_by_acct]   = MultidocTransactionByAccountReport.new(context).generate
    end

    do_receipt_reports = -> do
      if run_options.do_receipts
        reports_by_short_name[:receipts] = ReceiptsReport.new(context, *missing_existing_unused_receipts).generate
      end
    end

    do_single_account_reports = -> do
      chart_of_accounts.accounts.each do |account|
        short_name = ('acct_' + account.code).to_sym
        report = TxOneAccount.new(context, account.code).generate
        reports_by_short_name[short_name] = report
      end
    end

    do_transaction_reports.()
    do_receipt_reports.()
    do_single_account_reports.()

    reports_by_short_name
  end


  private def run_command(command)
    puts "\n----\nRunning command: #{command}"
    stdout, stderr, status = Open3.capture3(command)
    puts "Status was #{status}."
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
    required_exes = OS.mac? ? %w(textutil cupsfilter) : %w(txt2html wkhtmltopdf)
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


  private def write_report(report)

    short_name, report_text = report
    txt_filespec = build_filespec(output_dir, short_name, 'txt')
    html_filespec = build_filespec(output_dir, short_name, 'html')
    pdf_filespec = build_filespec(output_dir, short_name, 'pdf')

    File.write(txt_filespec, report_text)

    # Mac OS
    textutil = ->(font_size) do
      run_command("textutil -convert html -font 'Courier New Bold' -fontsize #{font_size} #{txt_filespec} -output #{html_filespec}")
    end
    cupsfilter = -> { run_command("cupsfilter #{txt_filespec} > #{pdf_filespec}") }

    # Linux
    txt2html = -> { run_command("txt2html --preformat_trigger_lines 0 #{txt_filespec} > #{html_filespec}") }
    html2pdf = -> { run_command("wkhtmltopdf #{html_filespec} #{pdf_filespec}") }

    if OS.mac?
      textutil.(11)
      cupsfilter.()
      # Use smaller size for the PDF but larger size for the web pages:
      textutil.(14)
    else
      txt2html.()
      html2pdf.()
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
