require 'amazing_print'
require 'os'

require_relative 'chart_of_accounts'
require_relative 'journal'
require_relative '../filters/journal_entry_filters'  # for shell mode
require_relative '../helpers/parse_helper'
require_relative '../reports/book_set_reporter'

require 'erb'
require 'open3'

module RockBooks

  class BookSet < Struct.new(:run_options, :chart_of_accounts, :journals)

    FILTERS = JournalEntryFilters


    def initialize(run_options, chart_of_accounts, journals)
      super
    end


    def journal_names
      journals.map(&:short_name)
    end
    alias_method :jnames, :journal_names


    # Note: Unfiltered!
    def all_acct_amounts
      @all_acct_amounts ||= Journal.acct_amounts_in_documents(journals)
    end


    def all_entries
      @all_entries ||= Journal.entries_in_documents(journals)
    end

  end
end

