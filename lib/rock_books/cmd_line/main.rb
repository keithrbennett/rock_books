require 'amazing_print'
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
    options.extra_output_line = DEFAULT_EXTRA_LINE_ENABLED
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

      parser.on("-h", "--help", "Show help") do |_help_requested|
        ARGV << 'h' # pass on the request to the command processor
        options.suppress_command_line_validation = true
      end

      message = "Include an extra line separating transactions in the output, default: #{DEFAULT_EXTRA_LINE_ENABLED}"
      parser.on('-e', '--[no-]extra_output_line [FLAG]', TrueClass, message) do |v|
        options.extra_output_line = (v.nil? ? true : v)
      end

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


  def call
    begin
      ARGV << '-h' if ARGV.empty?
      run_options = parse_command_line
      CommandLineInterface.new(run_options).call
    rescue => error
      $stderr.puts  \
      <<~HEREDOC
      #{error.backtrace.join("\n")}

      #{'-' * 79}
      #{error}
      #{'-' * 79}

      HEREDOC

      exit(-1)
      binding.pry
      raise error
    end

  end
end
end
