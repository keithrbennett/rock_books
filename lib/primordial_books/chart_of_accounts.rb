module PrimordialBooks
class ChartOfAccounts

  class Account < Struct.new(:id, :name); end

  attr_reader :date_prefix, :title, :accounts


  def initialize(input_string)
    @accounts = []
    lines = input_string.split("\n")
    lines.each { |line| parse_line(line) }
  end


  def parse_line(line)
    case line.strip
    when /^@title:/
      @title = line.split('title:').last.strip
    when /^@date_prefix:/
      @date_prefix = line.split('@date_prefix:').last.strip
    when /^$/
      # ignore empty line
    else
      # this is an account line in the form: 101 blah blah blah
      matcher = line.match(/^(\S+)\s+(.*)$/)
      accounts << Account.new(matcher[1], matcher[2])
    end
  end


  def report_string
    result = ''

    if title
      result << title << "\n\n"
    end

    id_width = @accounts.inject(0) { |width, a| width = [width, a.id.length].max }
    format_string = "%#{id_width}s  %s\n"
    accounts.each { |a| result << format_string % [a.id, a.name] }

    result
  end


  def name_for_id(id)
    found = accounts.detect { |a| a.id == id }
    found ? found.name : nil
  end
end
end
