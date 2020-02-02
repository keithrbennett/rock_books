module RockBooks
module HtmlHelper

  module_function

  def self.convert_receipts_to_hyperlinks(html_text)
    html_lines = html_text.split("\n")
    replacements_made = false

    html_lines.each_with_index do |line, index|
      matches = /Receipt:\s*(.*?)</.match(line)
      if matches
        receipt_filespec = matches[1]
        line_with_hyperlink = line.gsub( \
            /Receipt:\s*#{receipt_filespec}/, \
            %Q{Receipt: <a href="../../../receipts/#{receipt_filespec}">#{receipt_filespec}</a>})
        html_lines[index] = line_with_hyperlink
        replacements_made = true
      end
    end

    if replacements_made
      html_text = html_lines.join("\n")
    end

    [html_text, replacements_made]
  end
end
end
