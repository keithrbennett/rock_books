require_relative '../documents/book_set'

require_relative 'balance_sheet'
require_relative 'data/bs_is_data'
require_relative 'data/receipts_report_data'
require_relative 'income_statement'
require_relative 'index_html_page'
require_relative 'multidoc_txn_report'
require_relative 'receipts_report'
require_relative 'report_context'
require_relative 'journal_report'
require_relative 'multidoc_txn_by_account_report'
require_relative 'tx_one_account'
require_relative 'helpers/erb_helper'
require_relative 'helpers/text_report_helper'
require_relative 'helpers/receipts_hyperlink_converter'

require 'prawn'

module RockBooks
class BookSetReporter

  extend Forwardable

  attr_reader :book_set, :context, :filter, :output_dir

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
    create_directories
    create_index_html

    do_statements
    do_journals
    do_transaction_reports
    do_single_account_reports
    do_receipts_report
  end


  def get_all_report_data
    reports = {}

    reports[:bs_is] = BsIsData.new(context)

    reports[:journals] = journals.each_with_object({}) do |journal, journals|
      journals[journal.short_name] = JournalData.new(journal, context, filter).fetch
    end

    reports[:txn_reports] = {
      by_account: MultidocTxnByAccountData.new(context).fetch,
      by_date: MultidocTxnReportData.new(context, :date, filter).fetch,
      by_amount: MultidocTxnReportData.new(context, :amount, filter).fetch
    }

    reports[:single_accounts] = chart_of_accounts.accounts.each_with_object({}) do |account, single_accts|
      single_accts[account.code.to_sym] = TxOneAccountData.new(context, account.code).fetch
    end

    reports[:receipts] = ReceiptsReportData.new(book_set.all_entries, run_options.receipt_dir).fetch
    reports
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
    data = ReceiptsReportData.new(book_set.all_entries, run_options.receipt_dir).fetch
    text_report = ReceiptsReport.new(context, data).generate
    write_report(:receipts, text_report)
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


  private def report_metadata(doc_short_name)
    {
        RBCreator:      "RockBooks v#{VERSION} (#{PROJECT_URL})",
        RBEntity:       context.entity,
        RBCreated:      Time.now.to_s,
        RBDocumentCode: doc_short_name.to_s,
    }
  end


  private def prawn_create_document(pdf_filespec, report_text, doc_short_name)
    Prawn::Document.generate(pdf_filespec, info: report_metadata(doc_short_name)) do
      font(FONT_FILESPEC, size: 10)

      utf8_nonbreaking_space = "\uC2A0"
      unicode_nonbreaking_space = "\u00A0"
      text(report_text.gsub(' ', unicode_nonbreaking_space))
    end
  end


  private def html_metadata_comment(doc_short_name)
    "\n" + report_metadata(doc_short_name).ai(plain: true) + "\n"
  end


  private def write_report(short_name, text_report)

    txt_filespec = build_filespec(output_dir, short_name, 'txt')
    html_filespec = build_filespec(output_dir, short_name, 'html')
    pdf_filespec = build_filespec(output_dir, short_name, 'pdf')

    create_text_report = -> { File.write(txt_filespec, text_report) }

    create_pdf_report = -> { prawn_create_document(pdf_filespec, text_report, short_name) }

    create_html_report = -> do
      data = {
          report_body: text_report,
          title: "#{short_name} Report -- RockBooks",
          metadata_comment: html_metadata_comment(short_name)
      }
      html_raw_report = ErbHelper.render_hashes("html/report_page.html.erb", data, {})
      html_report = ReceiptsHyperlinkConverter.convert(html_raw_report, html_filespec)
      File.write(html_filespec, html_report)
    end

    create_text_report.()
    create_pdf_report.()
    create_html_report.()

    puts "Created text, PDF, and HTML reports for #{short_name}."
  end


  private def create_index_html
    filespec = build_filespec(output_dir, 'index', 'html')
    content = IndexHtmlPage.new(context, html_metadata_comment('index.html'), run_options).generate
    File.write(filespec, content)
    puts "Created index.html"
  end
end
end
