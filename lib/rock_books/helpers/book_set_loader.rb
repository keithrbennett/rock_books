require_relative '../documents/book_set'

module RockBooks

  # Entry point is `load` method. Loads files in a directory to instantiate a BookSet.
  module BookSetLoader

    module_function

    def get_files_with_types(directory)
      files = Dir[File.join(directory, '*.rbt')]
      files.each_with_object({}) do |filespec, files_with_types|
        files_with_types[filespec] = ParseHelper.find_document_type_in_file(filespec)
      end
    end


    def validate_chart_account_count(chart_of_account_files)
      size = chart_of_account_files.size

      if size == 0
        raise Error.new("Chart of accounts file not found in input directory.\n" +
                            " Does it have a '@doc_type: chart_of_accounts' line?")
      elsif size > 1
        raise Error.new("Expected only 1 chart of accounts file but found: #{chart_of_account_files}.")
      end
    end


    def validate_journal_file_count(journal_files)
      if journal_files.size == 0
        raise Error.new("No journal files found in directory #{directory}. " +
                            "A journal file must contain the line '@doc_type: journal'")
      end
    end


    def select_files_of_type(files_with_types, target_doc_type_regex)
      files_with_types.select { |filespec, doc_type| target_doc_type_regex === doc_type }.keys
    end


    # Uses all *.rbt files in the specified directory; uses @doc_type to determine which
    # is the chart of accounts and which are journals.
    # To exclude a file, make the extension other than .rdt.
    def load(directory)

      files_with_types = get_files_with_types(directory)

      chart_of_account_files = select_files_of_type(files_with_types, 'chart_of_accounts')
      validate_chart_account_count(chart_of_account_files)

      journal_files = select_files_of_type(files_with_types, /journal/) # include 'journal' and 'general_journal'
      validate_journal_file_count(journal_files)

      chart_of_accounts = ChartOfAccounts.from_file(chart_of_account_files.first)
      journals = journal_files.map { |fs| Journal.from_file(chart_of_accounts, fs) }
      BookSet.new(chart_of_accounts, journals)
    end

  end
end