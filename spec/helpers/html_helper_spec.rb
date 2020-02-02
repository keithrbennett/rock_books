require_relative '../../lib/rock_books/helpers/html_helper'

module RockBooks

  include HtmlHelper

  RSpec.describe RockBooks::HtmlHelper do

    input_line_with_spaces_after_colon = ->(num_spaces) do
      "<b>Receipt:#{' ' * num_spaces}01/2019-01-25-virginia-annual-corp-registration-fee.pdf</b>"
    end

    let(:expected_hyperlinked_receipt_line) do
      '<b>Receipt: <a href="../../../receipts/01/2019-01-25-virginia-annual-corp-registration-fee.pdf">01/2019-01-25-virginia-annual-corp-registration-fee.pdf</a></b>'
    end

    it 'returns the identical string when there are no receipt specifications' do
      string = '<p class="p1"><b>Totals</b></p>'
      expect(HtmlHelper.convert_receipts_to_hyperlinks(string)).to eq([string, false])
    end

    it 'returns an empty string for an empty string' do
      expect(HtmlHelper.convert_receipts_to_hyperlinks('')).to eq(['', false])
    end

    it 'hyperlinks a valid receipt line with 0 spaces after Receipt:' do
      input_line = input_line_with_spaces_after_colon.(0)
      expect(HtmlHelper.convert_receipts_to_hyperlinks(input_line)).to eq([expected_hyperlinked_receipt_line, true])
    end

    it 'hyperlinks a valid receipt line with 1 spaces after Receipt:' do
      input_line = input_line_with_spaces_after_colon.(1)
      expect(HtmlHelper.convert_receipts_to_hyperlinks(input_line)).to eq([expected_hyperlinked_receipt_line, true])
    end

    it 'hyperlinks a valid receipt line with 5 spaces after Receipt:' do
      input_line = input_line_with_spaces_after_colon.(5)
      expect(HtmlHelper.convert_receipts_to_hyperlinks(input_line)).to eq([expected_hyperlinked_receipt_line, true])
    end
  end
end
