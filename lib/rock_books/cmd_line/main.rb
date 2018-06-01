require 'optparse'
require 'pry'

require_relative '../documents/book_set'
require_relative 'command_line_interface'

module RockBooks

class Main

  # Parses the command line with Ruby's internal 'optparse'.
  # optparse removes what it processes from ARGV, which simplifies our command parsing.
  def parse_command_line
    options = OpenStruct.new

    OptionParser.new do |parser|

      parser.on("-e", "--entity_name NAME", "Entity name, for reports.") do |v|
        options.entity_name = v
      end

      parser.on("-i", "--input_dir DIR", "Input directory containing source data files") do |v|
        options.input_dir = File.expand_path(v)
      end

      parser.on("-o", "--output_dir DIR", "Output directory to which report files will be written") do |v|
        options.output_dir = File.expand_path(v)
      end

      parser.on("-s", "--shell", "Start interactive shell") do |v|
        options.interactive_mode = true
      end
    end.parse!

    options
  end


  # Arg is a directory containing 'chart_of_accounts.rbd' and '*journal*.rbd' for input,
  # and reports (*.rpt) will be output to this directory as well.
  def call
    options = parse_command_line
    CommandLineInterface.new(options).call
  end
end
end
