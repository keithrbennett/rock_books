require_relative 'book_set'

module RockBooks

  class Main

    # Arg is a directory containing 'chart_of_accounts.rbd' and '*journal*.rbd' for input,
    # and reports (*.rpt) will be output to this directory as well.
    def call
      input_directory = ARGV[0] || '.'
      output_directory = ARGV[1] || ARGV[0]
      book_set = BookSet.from_directory(input_directory)
      book_set.all_reports_to_files(output_directory)
    end
  end

end