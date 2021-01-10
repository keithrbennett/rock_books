module RockBooks
class ReceiptsHyperlinkConverter

  def self.convert(html_string, html_filespec)
    ReceiptsHyperlinkConverter.new(html_string, html_filespec).convert
  end

  RECEIPT_REGEX = /Receipt:\s*(\S*)/

  attr_reader :html_string, :num_dirs_up

  def initialize(html_string, html_filespec)
    @html_string = html_string
    @num_dirs_up = html_filespec.include?('/single-account/') ? 3 : 2
  end


  def convert
    html_string.split("\n").map do |line|
      matches = RECEIPT_REGEX.match(line)
      if matches
        listed_receipt_filespec = matches[1]
        receipt_anchor_line(line, listed_receipt_filespec)
      else
        line
      end
    end.join("\n")
  end


  # If the HTML file being created is in DATA_DIR/rockbooks-reports/html/single-account, then
  #   the processed link should be '../../../receipts/[receipt_filespec]'
  # else it's in DATA_DIR/rockbooks-reports/html, and
  #   the processed link should be '../../receipts/[receipt_filespec]'
  private def processed_receipt_filespec(listed_receipt_filespec)
    File.join(('../' * num_dirs_up), 'receipts', listed_receipt_filespec)
  end

  private def receipt_anchor_line(line, listed_receipt_filespec)
    line.gsub( \
          /Receipt:\s*#{listed_receipt_filespec}/, \
          %Q{Receipt: <a href="#{processed_receipt_filespec(listed_receipt_filespec)}">#{listed_receipt_filespec}</a>})
  end

end
end

