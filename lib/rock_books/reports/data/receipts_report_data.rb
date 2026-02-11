require 'pathname'

module RockBooks
class ReceiptsReportData

  attr_reader :all_entries, :receipt_dir

  def initialize(all_entries, receipt_dir)
    @all_entries = all_entries
    @receipt_dir = receipt_dir
  end


  def fetch
    missing_receipts = []
    existing_receipts = []

    # We will start out putting all filespecs in the unused array, and delete them as they are found in the transactions.
    unused_receipt_filespecs = all_receipt_filespecs

    all_entries.each do |entry|
      entry.receipts.each do |receipt|
                full_filespec = receipt_full_filespec(receipt)
                relative_filespec = Pathname.new(full_filespec).relative_path_from(Pathname.new(receipt_dir)).to_s
        
                unused_receipt_filespecs.delete(relative_filespec)
        
                list = (File.file?(full_filespec) ? existing_receipts : missing_receipts)
        list << { receipt: receipt, journal: entry.doc_short_name }
      end
    end

    [missing_receipts, existing_receipts].each do |receipt_list|
      receipt_list.uniq!
      receipt_list.sort_by! { |r| [r[:receipt], r[:journal]] }
    end

    {
        missing: missing_receipts,
        unused: unused_receipt_filespecs,
        existing: existing_receipts
    }
  end


  private def all_receipt_filespecs
    Dir[File.join(receipt_dir, 'receipts', '**', '*')].select { |s| File.file?(s) } \
        .sort \
        .map { |s| Pathname.new(s).relative_path_from(Pathname.new(receipt_dir)).to_s }
  end


  private def receipt_full_filespec(receipt_filespec)
    File.join(receipt_dir, receipt_filespec)
  end
end
end
