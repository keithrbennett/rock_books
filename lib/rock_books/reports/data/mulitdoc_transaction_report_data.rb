class MulitdocTransactionReportData

  def initialize(sort_by, filter = nil)
    entries = Journal.entries_in_documents(context.journals, filter)

    if sort_by == :amount
      JournalEntry.sort_entries_by_amount_descending!(entries)
    else
      # We assume that the data in the journals is already in date order.
      # In this way we can preserve the order of the transactions for the same date as in the journal.
      # Otherwise, transactions on the same date might be rearranged.
    end


  end
end