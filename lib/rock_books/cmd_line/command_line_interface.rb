require 'forwardable'
require 'ostruct'

require_relative '../../rock_books'
require_relative '../version'
require_relative '../reports/reporter'
require_relative '../helpers/book_set_loader'

module RockBooks

class CommandLineInterface

  # Enable users to type methods of this class more conveniently:
  include JournalEntryFilters
  extend Forwardable

  attr_reader :book_set, :interactive_mode, :run_options, :verbose_mode


  class Command < Struct.new(:min_string, :max_string, :action); end


  class BadCommandError < RuntimeError; end


  # Enable use of some BookSet methods in shell with long and short names aaa, ae:

  def_delegator :book_set, :all_acct_amounts
  def_delegator :book_set, :all_acct_amounts, :aaa

  def_delegator :book_set, :all_entries
  def_delegator :book_set, :all_entries, :ae

  def_delegator :book_set, :chart_of_accounts
  def_delegator :book_set, :chart_of_accounts, :chart

  # For conveniently finding the project on Github from the shell
  PROJECT_URL = 'https://github.com/keithrbennett/rock_books'

  # Help text to be used when requested by 'h' command, in case of unrecognized or nonexistent command, etc.
  HELP_TEXT = "
Command Line Switches:                    [rock-books version #{RockBooks::VERSION} at https://github.com/keithrbennett/rock_books]

-i   input directory specification, default: '#{DEFAULT_INPUT_DIR}'
-o   output (reports) directory specification, default: '#{DEFAULT_OUTPUT_DIR}'
-r   receipts directory, default: '#{DEFAULT_RECEIPT_DIR}'
-s   run in shell mode

Commands:

rec[eipts]                - receipts: a/:a all, m/:m missing, e/:e existing
rep[orts]                 - return an OpenStruct containing all reports (interactive shell mode only)
d[isplay_reports]         - display all reports on stdout
w[rite_reports]           - write all reports to the output directory (see -o option)
c[hart_of_accounts]       - chart of accounts
h[elp]                    - prints this help
jo[urnals]                - list of the journals' short names
rel[oad_data]             - reload data from input files
q[uit]                    - exits this program (interactive shell mode only) (see also 'x')
x[it]                     - exits this program (interactive shell mode only) (see also 'q')

When in interactive shell mode:
* use quotes for string parameters such as method names.
* for pry commands, use prefix `%`.
* you can use the global variable $filter to filter reports

"

  def initialize(run_options)
    @run_options = run_options
    @interactive_mode = !!(run_options.interactive_mode)
    @verbose_mode = run_options.verbose
    validate_run_options(run_options)
    # book_set is set with a lazy initializer
  end


  def validate_run_options(options)
    output = ''
    unless File.directory?(options.input_dir)
      output << "Input directory '#{options.input_dir}' does not exist. "
    end
    unless File.directory?(options.output_dir)
      output << "Output directory '#{options.output_dir}' does not exist. "
    end
    unless File.directory?(options.receipt_dir)
      output << "Receipts directory '#{options.receipt_dir}' does not exist. "
    end
    unless output.length == 0
      raise Error.new(output)
    end
  end


  def print_help
    puts HELP_TEXT
  end


  def enclose_in_hyphen_lines(string)
    hyphen_line = "#{'-' * 80}\n"
    hyphen_line + string + "\n" + hyphen_line
  end


  # Pry will output the content of the method from which it was called.
  # This small method exists solely to reduce the amount of pry's output
  # that is not needed here.
  def run_pry
    binding.pry

    # the seemingly useless line below is needed to avoid pry's exiting
    # (see https://github.com/deivid-rodriguez/pry-byebug/issues/45)
    _a = nil
  end


  # Runs a pry session in the context of this object.
  # Commands and options specified on the command line can also be specified in the shell.
  def run_shell
    begin
      require 'pry'
    rescue LoadError
      message = "The 'pry' gem and/or one of its prerequisites, required for running the shell, was not found." +
          " Please `gem install pry` or, if necessary, `sudo gem install pry`."
      raise Error.new(message)
    end

    print_help

    # Enable the line below if you have any problems with pry configuration being loaded
    # that is messing up this runtime use of pry:
    # Pry.config.should_load_rc = false

    # Strangely, this is the only thing I have found that successfully suppresses the
    # code context output, which is not useful here. Anyway, this will differentiate
    # a pry command from a DSL command, which _is_ useful here.
    Pry.config.command_prefix = '%'

    run_pry
  end


  # Look up the command name and, if found, run it. If not, execute the passed block.
  def attempt_command_action(command, *args, &error_handler_block)
    no_command_specified = command.nil?
    command = 'help' if no_command_specified

    action = find_command_action(command)
    result = nil

    if action
      result = action.(*args)
    else
      error_handler_block.call
      nil
    end

    if no_command_specified
      puts enclose_in_hyphen_lines('! No operations specified !')
    end
    result
  end


  # For use by the shell when the user types the DSL commands
  def method_missing(method_name, *method_args)
    attempt_command_action(method_name.to_s, *method_args) do
      puts(%Q{"#{method_name}" is not a valid command or option. } \
        << 'If you intend for this to be a string literal, ' \
        << 'use quotes or %q{}/%Q{}.')
    end
  end


  # Processes the command (ARGV[0]) and any relevant options (ARGV[1..-1]).
  #
  # CAUTION! In interactive mode, any strings entered (e.g. a network name) MUST
  # be in a form that the Ruby interpreter will recognize as a string,
  # i.e. single or double quotes, %q, %Q, etc.
  # Otherwise it will assume it's a method name and pass it to method_missing!
  def process_command_line
    attempt_command_action(ARGV[0], *ARGV[1..-1]) do
      print_help
      raise BadCommandError.new(
          %Q{! Unrecognized command. Command was #{ARGV.first.inspect} and options were #{ARGV[1..-1].inspect}.})
    end
  end


  def quit
    if interactive_mode
      exit(0)
    else
      puts "This command can only be run in shell mode."
    end
  end


  def cmd_c
    puts chart_of_accounts.report_string
  end


  def cmd_h
    print_help
  end


  def cmd_j
    journal_names = book_set.journals.map(&:short_name)
    interactive_mode ? journal_names : ap(journal_names)
  end


  def book_set
    @book_set ||= load_data
  end


  def load_data
    @book_set = BookSetLoader.load(run_options)
  end
  alias_method :reload_data, :load_data


  def cmd_rel
    reload_data
    nil
  end


  # All reports as Ruby objects; only makes sense in shell mode.
  def cmd_rep
    unless run_options.interactive_mode
      raise Error.new("Option 'all_reports' is only available in shell mode. Try 'display_reports' or 'write_reports'.")
    end

    os = OpenStruct.new(book_set.all_reports($filter))
    def os.keys; to_h.keys;     end  # add hash methods for convenience
    def os.values; to_h.values; end
    def os.at(index); self.public_send(keys[index]); end # to access as array, e.g. `a.at(1)`
    os
  end


  def cmd_d
    book_set.all_reports($filter).each do |short_name, report_text|
      puts "#{short_name}:\n\n"
      puts report_text
      puts "\n\n\n"
    end
  end


  def cmd_proj
    `open https://github.com/keithrbennett/rock_books`
  end


  def cmd_rec(options)
    missing, existing = book_set.missing_and_existing_receipts

    print_missing  = -> { puts "Missing Receipts:"; ap missing }
    print_existing = -> { puts "Existing Receipts:"; ap existing }

    case options.first.to_s
      when 'a'  # all
        if run_options.interactive_mode
          [missing, existing]
        else
           print_missing.(); print_existing.()
        end

      when 'm'
        run_options.interactive_mode ? missing : print_missing.()

      when 'e'
        run_options.interactive_mode ? existing : print_existing.()
    end
  end

  def cmd_w
    book_set.all_reports_to_files(run_options.output_dir, $filter)
  end


  def cmd_x
    quit
  end


  def commands
    @commands_ ||= [
        Command.new('rec', 'receipts',          -> (*options)  { cmd_rec(options)  }),
        Command.new('rep', 'reports',           -> (*_options) { cmd_rep           }),
        Command.new('d',   'display_reports',   -> (*_options) { cmd_d             }),
        Command.new('w',   'write_reports',     -> (*_options) { cmd_w             }),
        Command.new('c',   'chart_of_accounts', -> (*_options) { cmd_c             }),
        Command.new('jo',  'journals',          -> (*_options) { cmd_j             }),
        Command.new('h',   'help',              -> (*_options) { cmd_h             }),
        Command.new('proj','project_page',      -> (*_options) { cmd_proj          }),
        Command.new('q',   'quit',              -> (*_options) { cmd_x             }),
        Command.new('rel', 'reload_data',       -> (*_options) { cmd_rel           }),
        Command.new('x',   'xit',               -> (*_options) { cmd_x             })
    ]
  end


  def find_command_action(command_string)
    result = commands.detect do |cmd|
      cmd.max_string.start_with?(command_string) \
    && \
    command_string.length >= cmd.min_string.length  # e.g. 'c' by itself should not work
    end
    result ? result.action : nil
  end


  # If a post-processor has been configured (e.g. YAML or JSON), use it.
  def post_process(object)
    post_processor ? post_processor.(object) : object
  end


  def post_processor
    run_options.post_processor
  end


  # Convenience Method(s)

  # Easier than remembering and typing Date.iso8601.
  def td(date_string)
    Date.iso8601(date_string)
  end


  def call
    begin
      # By this time, the Main class has removed the command line options, and all that is left
      # in ARGV is the commands and their options.
      if @interactive_mode
        run_shell
      else
        process_command_line
      end

    rescue BadCommandError => error
      separator_line = "! #{'-' * 75} !\n"
      puts '' << separator_line << error.to_s << "\n" << separator_line
      exit(-1)
    end
  end
end
end
