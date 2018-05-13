module PrimordialBooks
  class ChartOfAccounts

    class Account < Struct.new(:id, :name); end

    attr_reader :title

    def initialize(input_string)
      lines = input_string.split("\n")
      lines.each do |line|
        puts line
        case line
        when /^@title:/
          $stderr.puts "\n\nfound title line"; $stderr.puts line
          @title = line.split('title:').last.strip
        end
      end
    end

  end
end