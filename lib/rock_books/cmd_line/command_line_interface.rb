require 'ostruct'

require_relative '../version'
require_relative '../helpers/book_set_loader'

module RockBooks

  class CommandLineInterface

    # Enable users to type methods of this class more conveniently:
    include JournalEntryFilters


    attr_reader :book_set, :entity_name, :interactive_mode, :options


    class Command < Struct.new(:min_string, :max_string, :action); end


    class BadCommandError < RuntimeError; end


    # Help text to be used when requested by 'h' command, in case of unrecognized or nonexistent command, etc.
    HELP_TEXT = "
Command Line Switches:                    [rock-books version #{RockBooks::VERSION} at https://github.com/keithrbennett/rock_books]

-o {i,j,k,p,y}            - outputs data in inspect, JSON, pretty JSON, puts, or YAML format when not in shell mode
-s                        - run in shell mode
-v                        - verbose mode

Commands:

a[ll_reports]             - generate all reports; options: 'p': print, 'w': write to files
e[ntity_name]             - entity name for reports
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

    def initialize(options)
      @options = options
      @interactive_mode = !!(options.interactive_mode)
      @entity_name = options.entity_name
      load_data
    end


    # Until command line option parsing is added, the only way to specify
    # verbose mode is in the environment variable MAC_WIFI_OPTS.
    def verbose_mode
      options.verbose
    end


    def print_help
      puts HELP_TEXT
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
      action = find_command_action(command)

      if action
        action.(*args)
      else
        error_handler_block.call
        nil
      end
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
            %Q{! Unrecognized command. Command was "#{ARGV.first.inspect}" and options were #{ARGV[1..-1].inspect}.})
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
      puts book_set.chart_of_accounts.report_string
    end


    def cmd_h
      print_help
    end


    def cmd_j
      journal_names = book_set.journals.map(&:short_name)
      if interactive_mode
        journal_names
      else
        ap journal_names
      end
    end


    def load_data
      @book_set = BookSetLoader.load(entity_name, options.input_dir)
    end
    alias_method :reload_data, :load_data


    def cmd_rel
      reload_data
      nil
    end


    def cmd_a(args)
      choice = args&.first&.chars&.first

      case choice
      when 'p'
        book_set.all_reports($filter).each do |short_name, report_text|
          puts "#{short_name}:\n\n"
          puts report_text
          puts "\n\n\n"
        end
        nil
      when 'w'
        book_set.all_reports_to_files(options.output_dir, $filter)
        nil
      when nil
        os = OpenStruct.new(book_set.all_reports($filter))
        def os.keys; to_h.keys;     end  # add hash methods for convenience
        def os.values; to_h.values; end
        def os.at(index); self.public_send(keys[index]); end # to access as array, e.g. `a.at(1)`
        os
      else
        raise Error.new("Invalid option '#{choice} for all_reports; must be in #{%w(p w)} or nil.")
      end
    end


    def cmd_e(args)
      self.entity_name = args.first
    end


    def cmd_x
      quit
    end


    def commands
      @commands_ ||= [
          Command.new('a',   'all_reports',       -> (*options)  { cmd_a(options)    }),
          Command.new('c',   'chart_of_accounts', -> (*options)  { cmd_c             }),
          Command.new('e',   'entity_name',       -> (*options)  { cmd_e             }),
          Command.new('jo',  'journals',          -> (*_options) { cmd_j             }),
          Command.new('h',   'help',              -> (*_options) { cmd_h             }),
          Command.new('q',   'quit',              -> (*_options) { cmd_x             }),
          Command.new('r',   'reload_data',       -> (*_options) { cmd_rel           }),
          Command.new('x',   'xit',               -> (*_options) { cmd_x             })
      ]
    end


    def find_command_action(command_string)
      # puts "command string: " + command_string
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
      options.post_processor
    end


    # Convenience Method(s)

    # Easier than remembering and typing Date.iso8601.
    def td(date_string)
      Date.iso8601(date_string)
    end


    def chart_of_accounts
      book_set.chart_of_accounts
    end
    alias_method :chart, :chart_of_accounts


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