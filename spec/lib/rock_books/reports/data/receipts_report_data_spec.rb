# spec/lib/rock_books/reports/data/receipts_report_data_spec.rb

require 'spec_helper'
require 'rock_books/reports/data/receipts_report_data'
require 'rock_books/documents/journal_entry'
require 'fileutils'
require 'tmpdir'
require 'date' # Added for Date.parse


RSpec.describe RockBooks::ReceiptsReportData do
  subject { RockBooks::ReceiptsReportData.new(all_entries, receipt_dir) }

  let(:journal_entry_class) do
    Class.new(RockBooks::JournalEntry) do
      def self.[](date, acct_amounts, doc_short_name, description, receipts)
        new(date, acct_amounts, doc_short_name, description, receipts)
      end
    end
  end

    let(:all_entries) { [] }
    let(:receipt_dir) { Dir.mktmpdir }

    before do
      FileUtils.mkdir_p(File.join(receipt_dir, 'receipts'))
    end

    after do
      FileUtils.remove_entry(receipt_dir)
    end

    def create_receipt_file(relative_path)
      full_path = File.join(receipt_dir, relative_path)
      FileUtils.mkdir_p(File.dirname(full_path))
      FileUtils.touch(full_path)
      File.join('receipts', relative_path.split('receipts/').last) # return path relative to receipt_dir/receipts
    end

    def create_journal_entry(date_string, doc_short_name, receipts_array)
      all_entries << journal_entry_class[
        Date.parse(date_string),
        [], # acct_amounts
        doc_short_name,
        'description',
        receipts_array
      ]
    end

    context 'when handling existing_receipts' do
      let(:receipt_a) { create_receipt_file('receipts/2023-01-01-a.jpg') }
      let(:receipt_b) { create_receipt_file('receipts/2023-01-02-b.png') }
      let(:receipt_c) { create_receipt_file('receipts/2023-01-03-c.pdf') }

      before do
        create_journal_entry('2023-01-01', 'journal_x', [receipt_b, receipt_a])
        create_journal_entry('2023-01-02', 'journal_y', [receipt_a, receipt_c])
        create_journal_entry('2023-01-03', 'journal_x', [receipt_b]) # Duplicate receipt_b for journal_x
      end

      it 'sorts existing_receipts by receipt filespec then journal short name' do
        result = subject.fetch
        expect(result[:existing]).to eq([
          { receipt: receipt_a, journal: 'journal_x' },
          { receipt: receipt_a, journal: 'journal_y' },
          { receipt: receipt_b, journal: 'journal_x' },
          { receipt: receipt_c, journal: 'journal_y' },
        ])
      end

      it 'removes duplicate existing_receipts (same receipt, same journal)' do
        # Add an entry that creates an identical existing_receipt hash
        create_journal_entry('2023-01-04', 'journal_x', [receipt_a])
        result = subject.fetch
        expect(result[:existing].count { |r| r == { receipt: receipt_a, journal: 'journal_x' } }).to eq(1)
      end
    end

    context 'when handling missing_receipts' do
      let(:missing_receipt_d) { File.join('receipts', '2023-01-04-d.jpg') }
      let(:missing_receipt_e) { File.join('receipts', '2023-01-05-e.png') }
      let(:missing_receipt_f) { File.join('receipts', '2023-01-06-f.pdf') }

      before do
        create_journal_entry('2023-01-04', 'journal_p', [missing_receipt_e, missing_receipt_d])
        create_journal_entry('2023-01-05', 'journal_q', [missing_receipt_d, missing_receipt_f])
        create_journal_entry('2023-01-06', 'journal_p', [missing_receipt_e]) # Duplicate missing_receipt_e for journal_p
      end

      it 'sorts missing_receipts by receipt filespec then journal short name' do
        result = subject.fetch
        expect(result[:missing]).to eq([
          { receipt: missing_receipt_d, journal: 'journal_p' },
          { receipt: missing_receipt_d, journal: 'journal_q' },
          { receipt: missing_receipt_e, journal: 'journal_p' },
          { receipt: missing_receipt_f, journal: 'journal_q' },
        ])
      end

      it 'removes duplicate missing_receipts (same receipt, same journal)' do
        # Add an entry that creates an identical missing_receipt hash
        create_journal_entry('2023-01-07', 'journal_p', [missing_receipt_d])
        result = subject.fetch
        expect(result[:missing].count { |r| r == { receipt: missing_receipt_d, journal: 'journal_p' } }).to eq(1)
      end
    end

    context 'when handling unused_receipt_filespecs' do
      let!(:existing_on_disk_a) { create_receipt_file('receipts/alpha.jpg') }
      let!(:existing_on_disk_b) { create_receipt_file('receipts/beta.png') }
      let!(:existing_on_disk_c) { create_receipt_file('receipts/gamma.pdf') }

      before do
        # Reference 'alpha.jpg' in a journal entry, leaving 'beta.png' and 'gamma.pdf' unused
        create_journal_entry('2023-02-01', 'journal_z', [existing_on_disk_a])
      end

      it 'sorts unused_receipt_filespecs alphabetically' do
        result = subject.fetch
              expect(result[:unused]).to eq([
                'receipts/beta.png',
                'receipts/gamma.pdf',
              ])      end
    end
end # Added this missing 'end'