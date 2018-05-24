require_relative 'chart_of_accounts'
require_relative 'journal'
require_relative 'multidoc_transaction_report'

module RockBooks

  class BookSet < Struct.new(:chart_of_accounts, :journals)

    def self.from_files(chart_of_accounts_filespec, journal_filespecs)
      chart_of_accounts = ChartOfAccounts.from_file(chart_of_accounts_filespec)
      journals = journal_filespecs.map { |fs| Journal.from_file(chart_of_accounts, fs) }
      self.new(chart_of_accounts, journals)
    end


    def transaction_report
      MultidocTransactionReport.new(journals, chart_of_accounts).call
    end
  end

end
