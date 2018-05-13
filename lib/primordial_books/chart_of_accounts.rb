module PrimordialBooks
  class ChartOfAccounts

    class Account < Struct.new(:id, :name); end

    attr_reader :date_prefix, :title, :accounts

    def initialize(input_string)
      @accounts = []
      lines = input_string.split("\n")
      lines.each do |line|
        puts line
        case line.strip
        when /^@title:/
          @title = line.split('title:').last.strip
        when /^@date_prefix:/
          puts 'found date prefix'
          @date_prefix = line.split('@date_prefix:').last.strip
        when /^$/
          # ignore empty line
        else
          # this is an account line in the form: 101 blah blah blah
          matcher = line.match(/^(\S+)\s+(.*)$/)
          @accounts << Account.new(matcher[1], matcher[2])
        end
      end
    end

  end
end