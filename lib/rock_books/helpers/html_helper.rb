module RockBooks
module HtmlHelper

  def self.convert_receipts_to_hyperlinks_in_file(filespec)
    before_string = File.read(filespec)
    content_changed, after_string =  convert_receipts_to_hyperlinks_in_string(before_string, filespec)
    if content_changed
      File.write(filespec, after_string)
    end
    content_changed
  end


  def self.convert_receipts_to_hyperlinks_in_string(original_html_string, html_filespec)
    html_lines = original_html_string.split("\n")
    content_changed = false

    # If the HTML file being created is in DATA_DIR/rockbooks-reports/html/single-account, then
    #   the relative link should be '../../../receipts/[receipt_filespec]'
    # else it's in DATA_DIR/rockbooks-reports/html, and
    #   the relative link should be '../../receipts/[receipt_filespec]'
    processed_receipt_filespec = ->(listed_receipt_filespec) do
      num_dirs_up = html_filespec.include?('/single-account/') ? 3 : 2
      File.join(('../' * num_dirs_up), 'receipts', listed_receipt_filespec)
    end

    receipt_anchor_line = ->(line, listed_receipt_filespec) do
      line.gsub( \
            /Receipt:\s*#{listed_receipt_filespec}/, \
            %Q{Receipt: <a href="#{processed_receipt_filespec.(listed_receipt_filespec)}">#{listed_receipt_filespec}</a>})
    end

    html_lines.each_with_index do |line, index|
      matches = /Receipt:\s*(\S*)/.match(line)
      if matches
        listed_receipt_filespec = matches[1]
        html_lines[index] = receipt_anchor_line.(line, listed_receipt_filespec)
        content_changed = true
      end
    end

    [content_changed, content_changed ? html_lines.join("\n") : original_html_string]
  end
end
end
