module RockBooks
class ReceiptsHyperlinkConverter

  def self.convert(html_string, html_filespec)
    ReceiptsHyperlinkConverter.new(html_string, html_filespec).convert
  end

  RECEIPT_REGEX = /Receipt:\s*(\S*)/
  INVOICE_REGEX = /Invoice:\s*(\S*)/

  attr_reader :html_string, :num_dirs_up

  def initialize(html_string, html_filespec)
    @html_string = html_string
    @num_dirs_up = html_filespec.include?('/single-account/') ? 3 : 2
  end


  def convert
    process_link_type = ->(line, regex, dir_name) do
      matches = regex.match(line)
      if matches
        listed_filespec = matches[1]
        anchor_line(line, listed_filespec, dir_name)
      else
        line
      end
    end

    html_string.split("\n").map do |line|
      line = process_link_type.(line, RECEIPT_REGEX, 'receipts')
      process_link_type.(line, INVOICE_REGEX, 'invoices')
    end.join("\n")
  end


  # If the HTML file being created is in DATA_DIR/rockbooks-reports/html/single-account, then
  #   the processed link should be '../../../receipts/[receipt_filespec]'
  # else it's in DATA_DIR/rockbooks-reports/html, and
  #   the processed link should be '../../receipts/[receipt_filespec]'
  #
  # `dir_name` will be 'receipts' or 'invoices'
  private def dirized_filespec(listed_filespec, dir_name)
    File.join(('../' * num_dirs_up), dir_name, listed_filespec)
  end

  private def anchor_line(line, listed_filespec, dir_name)
    label = {
      'receipts' => 'Receipt',
      'invoices' => 'Invoice'
    }.fetch(dir_name)

    line.gsub( \
          /#{label}:\s*#{listed_filespec}/, \
          %Q{#{label}: <a href="#{dirized_filespec(listed_filespec, dir_name)}">#{listed_filespec}</a>})
  end
end
end

