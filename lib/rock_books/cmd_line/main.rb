require 'awesome_print'
require 'optparse'
require 'pry'
require 'shellwords'

require_relative '../../rock_books'
require_relative '../documents/book_set'
require_relative 'command_line_interface'

module RockBooks

class Main


  def options_with_defaults
    options = OpenStruct.new
    options.input_dir   = DEFAULT_INPUT_DIR
    options.output_dir  = DEFAULT_OUTPUT_DIR
    options.receipt_dir = DEFAULT_RECEIPT_DIR
    options.do_receipts = true
    options
  end


  def prepend_environment_options
    env_opt_string = ENV['ROCKBOOKS_OPTIONS']
    if env_opt_string
      args_to_prepend = Shellwords.shellsplit(env_opt_string)
      ARGV.unshift(args_to_prepend).flatten!
    end
  end


  # Parses the command line with Ruby's internal 'optparse'.
  # OptionParser#parse! removes what it processes from ARGV, which simplifies our command parsing.
  def parse_command_line
    prepend_environment_options
    options = options_with_defaults

    OptionParser.new do |parser|

      parser.on('-i', '--input_dir DIR',
          "Input directory containing source data files, default: '#{DEFAULT_INPUT_DIR}'") do |v|
        options.input_dir = File.expand_path(v)
      end

      parser.on('-o', '--output_dir DIR',
          "Output directory to which report files will be written, default: '#{DEFAULT_OUTPUT_DIR}'") do |v|
        options.output_dir = File.expand_path(v)
      end

      parser.on('-r', '--receipt_dir DIR',
          "Directory root from which to find receipt filespecs, default: '#{DEFAULT_RECEIPT_DIR}'") do |v|
        options.receipt_dir = File.expand_path(v)
      end

      parser.on('-s', '--shell', 'Start interactive shell') do |v|
        options.interactive_mode = true
      end

      parser.on('-v', '--[no-]verbose', 'Verbose mode') do |v|
        options.verbose_mode = v
      end

      parser.on('-y', '--[no-]say', 'Say error messages.') do |v|
        options.say = v
      end

      parser.on('', '--[no-]receipts', 'Include report on existing and missing receipts.') do |v|
        options.do_receipts = v
      end
    end.parse!

    if options.verbose_mode
      puts "Run Options:"
      ap options.to_h
    end

    options
  end


  # Arg is a directory containing 'chart_of_accounts.rbd' and '*journal*.rbd' for input,
  # and reports (*.rpt) will be output to this directory as well.
  def call
    begin
      run_options = parse_command_line
      CommandLineInterface.new(run_options).call
    rescue => error
      $stderr.puts  \
      <<~HEREDOC
      #{error.backtrace.join("\n")}

      #{error}
      HEREDOC

      if run_options.say
        `say #{error}`
      end

      exit(-1)
      binding.pry
      raise error
    end

  end
end
end
