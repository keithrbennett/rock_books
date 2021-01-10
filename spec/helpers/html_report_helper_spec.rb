require_relative '../../lib/rock_books/reports/helpers/receipts_hyperlink_converter'

module RockBooks

  include HtmlReportHelper

  RSpec.describe RockBooks::HtmlReportHelper do

    let(:receipt_filename) { '01/2019-01-25-virginia-annual-corp-registration-fee.pdf' }

    let(:input_line_with_spaces_after_colon) do
      ->(num_spaces) do
        "Receipt:#{' ' * num_spaces}#{receipt_filename}"
      end
    end

    let(:expected_hyperlinked_receipt_line) do
      ->(filespec) do
        up_spec = filespec.include?('/single-account/') ? '../../../' : '../../'
        %Q{Receipt: <a href="#{up_spec}receipts/01/2019-01-25-virginia-annual-corp-registration-fee.pdf">01/2019-01-25-virginia-annual-corp-registration-fee.pdf</a>}
      end
    end

    it 'returns the identical string when there are no receipt specifications' do
      string = '<p class="p1">Totals</p>'
      expect(HtmlReportHelper.convert_receipts_to_hyperlinks(string, '')).to eq(string)
    end

    it 'returns an empty string for an empty string' do
      expect(HtmlReportHelper.convert_receipts_to_hyperlinks('', '')).to eq('')
    end

    it 'hyperlinks a valid receipt line with 0 spaces after Receipt:' do
      input_line = input_line_with_spaces_after_colon.(0)
      expect(HtmlReportHelper.convert_receipts_to_hyperlinks(input_line, '')).to eq(expected_hyperlinked_receipt_line.(''))
    end

    it 'hyperlinks a valid receipt line with 1 spaces after Receipt:' do
      input_line = input_line_with_spaces_after_colon.(1)
      expect(HtmlReportHelper.convert_receipts_to_hyperlinks(input_line, '')).to eq(expected_hyperlinked_receipt_line.(''))
    end

    it 'hyperlinks a valid receipt line with 5 spaces after Receipt:' do
      input_line = input_line_with_spaces_after_colon.(5)
      expect(HtmlReportHelper.convert_receipts_to_hyperlinks(input_line, '')).to eq(expected_hyperlinked_receipt_line.(''))
    end

    specify "href includes '../../..'' only if filespec includes 'single-account'" do
      input_line = input_line_with_spaces_after_colon.(5)
      expect(HtmlReportHelper.convert_receipts_to_hyperlinks(input_line, 'x/single-account/y')).to     include('../../../')
      expect(HtmlReportHelper.convert_receipts_to_hyperlinks(input_line, 'x/triple-account/y')).not_to include('../../../')
    end
  end
end
