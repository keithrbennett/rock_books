require_relative 'report_context'


module RockBooks
class ReceiptsReport

  include Reporter

  attr_reader :context, :missing, :existing, :unused


  def initialize(report_context, missing, existing, unused)
    @context = report_context
    @missing = missing
    @existing = existing
    @unused = unused
  end


  def generate_header
    lines = [banner_line]
    lines << center(context.entity || 'Unspecified Entity')
    lines << "#{center("Receipts Report")}"
    lines << banner_line
    lines.join("\n")
  end


  def receipt_info_line(info)
    sprintf("%-16.16s  %s\n", info[:journal], info[:receipt])
  end


  def column_headings
    format_string = "%-16.16s  %s\n"
    sprintf(format_string, 'Journal', 'Receipt Filespec') \
        + sprintf(format_string, '-------', '----------------') \
        + "\n"
  end


  def report_one_section(name, list)
    output = ''
    output << "\n\n\n#{name} Receipts:\n\n" << column_headings
    if list.empty?
      output << "[None]\n\n\n"
    else
      list.each { |receipt| output << receipt_info_line(receipt) }
    end
    output
  end


  def generate
    output = generate_header
    output << report_one_section('Missing',  missing)

    output << "\n\n\nUnused Receipts:\n\n"
    if unused.empty?
      output << "[None]\n\n\n"
    else
      unused.each { |filespec| output << filespec << "\n" }
    end

    output << report_one_section('Existing', existing)
    output
  end
end
end