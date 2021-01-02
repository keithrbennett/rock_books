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
        filespec = receipt_full_filespec(receipt)
        unused_receipt_filespecs.delete(filespec)
        list = (File.file?(filespec) ? existing_receipts : missing_receipts)
        list << { receipt: receipt, journal: entry.doc_short_name }
      end
    end

    {
        missing: missing_receipts,
        unused: unused_receipt_filespecs,
        existing: existing_receipts
    }
  end


  private def all_receipt_filespecs
    Dir['receipts/**/*'].select { |s| File.file?(s) } \
        .sort \
        .map { |s| "./" +  s }  # Prepend './' to match the data
  end


  private def receipt_full_filespec(receipt_filespec)
    File.join(receipt_dir, receipt_filespec)
  end
end
end
