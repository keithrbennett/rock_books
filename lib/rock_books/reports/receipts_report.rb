require_relative 'report_context'


module RockBooks
class ReceiptsReport

  include Reporter

  attr_reader :context, :missing, :existing


  def initialize(report_context, missing, existing)
    @context = report_context
    @missing = missing
    @existing = existing
  end


  def generate_header
    lines = [banner_line]
    lines << center(context.entity || 'Unspecified Entity')
    lines << "#{center("Receipts Report")}"
    lines << banner_line
    lines << ''
    lines << ''
    lines << ''
    lines.join("\n")
  end


  def receipt_info_line(info)
    "%-16.16s  %s\n" % [info[:journal], info[:receipt]]
  end


  def column_headings
    format_string = "%-16.16s  %s\n"
    (format_string % ['Journal', 'Receipt Filespec']) << (format_string % %w(------- ----------------)) << "\n"
  end


  def generate_report
    output = generate_header

    output << "Missing Receipts:\n\n" << column_headings
    missing.each { |info| output << receipt_info_line(info) }

    output << "\n\n\nExisting Receipts:\n\n" << column_headings
    existing.each { |info| output << receipt_info_line(info) }

    output
  end

  alias_method :to_s, :generate_report
  alias_method :call, :generate_report
end
end