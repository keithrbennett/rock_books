require_relative '../../lib/rock_books/helpers/html_helper'

module RockBooks

  include HtmlHelper

  RSpec.describe RockBooks::HtmlHelper do

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
      expect(HtmlHelper.convert_receipts_to_hyperlinks_in_string(string, '')).to eq([false, string])
    end

    it 'returns an empty string for an empty string' do
      expect(HtmlHelper.convert_receipts_to_hyperlinks_in_string('', '')).to eq([false, ''])
    end

    it 'hyperlinks a valid receipt line with 0 spaces after Receipt:' do
      input_line = input_line_with_spaces_after_colon.(0)
      expect(HtmlHelper.convert_receipts_to_hyperlinks_in_string(input_line, '')).to eq([true, expected_hyperlinked_receipt_line.('')])
    end

    it 'hyperlinks a valid receipt line with 1 spaces after Receipt:' do
      input_line = input_line_with_spaces_after_colon.(1)
      expect(HtmlHelper.convert_receipts_to_hyperlinks_in_string(input_line, '')).to eq([true, expected_hyperlinked_receipt_line.('')])
    end

    it 'hyperlinks a valid receipt line with 5 spaces after Receipt:' do
      input_line = input_line_with_spaces_after_colon.(5)
      expect(HtmlHelper.convert_receipts_to_hyperlinks_in_string(input_line, '')).to eq([true, expected_hyperlinked_receipt_line.('')])
    end

    specify "href includes '../../..'' only if filespec includes 'single-account'" do
      input_line = input_line_with_spaces_after_colon.(5)
      expect(HtmlHelper.convert_receipts_to_hyperlinks_in_string(input_line, 'x/single-account/y').last).to include('../../../')
      expect(HtmlHelper.convert_receipts_to_hyperlinks_in_string(input_line, 'x/triple-account/y').last).not_to include('../../../')
    end
  end
end
