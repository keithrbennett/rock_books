require_relative '../types/account'
require_relative '../types/account_type'
require_relative '../errors/error'

module RockBooks
class ChartOfAccounts

  attr_reader :doc_type, :title, :accounts, :entity


  def self.from_file(file)
    self.new(File.read(file))
  end


  def initialize(input_string)
    @accounts = []
    lines = input_string.split("\n")
    lines.each { |line| parse_line(line) }
  end


  def parse_line(line)
    case line.strip
    when /^@doc_type:/
      @doc_type = line.split('@doc_type:').last.strip
    when /^@entity:/
      @entity ||= line.split('@entity:').last.strip
    when /^@title:/
      @title = line.split('@title:').last.strip
    when /^$/
      # ignore empty line
    when /^#/
      # ignore comment line
    else
      # this is an account line in the form: 101 Asset First National City Bank
      # The regex below gets everything before the first whitespace in token 1, and the rest in token 2.
      matcher = line.match(/^(\S+)\s+(.*)$/)
      code = matcher[1]
      rest = matcher[2]

      matcher = rest.match(/^(\S+)\s+(.*)$/)
      account_type_token = matcher[1]
      account_type = AccountType.to_type(account_type_token).symbol

      name = matcher[2]

      accounts << Account.new(code, account_type, name)
    end
  end

  def accounts_of_type(type)
    accounts.select { |account| account.type == type }
  end

  def account_codes_of_type(type)
    accounts_of_type(type).map(&:code)
  end


  def include?(candidate_code)
    accounts.any? { |account| account.code == candidate_code }
  end


  def report_string
    result = ''

    if title
      result << title << "\n\n"
    end

    code_width = @accounts.inject(0) { |width, a| width = [width, a.code.length].max }
    format_string = "%-#{code_width}s  %-10.10s  %s\n"
    accounts.each { |a| result << (format_string % [a.code, a.type.to_s, a.name]) }

    result
  end


  def account_for_code(code)
    accounts.detect { |a| a.code == code }
  end


  def type_for_code(code)
    found = account_for_code(code)
    found ? found.type : nil
  end

  def name_for_code(code)
    found = account_for_code(code)
    found ? found.name : nil
  end


  def max_account_code_length
    @max_account_code_length ||= accounts.map { |a| a.code.length }.max
  end


  def debit_or_credit_for_code(code)
    type = type_for_code(code)
    if %i(asset  expense).include?(type)
      :debit
    elsif %i(liability  equity  income).include?(type)
      :credit
    else
      raise "Unexpected type #{type} for code #{code}."
    end
  end


  def ==(other)
    doc_type == other.doc_type   && \
    title    == other.title      && \
    accounts == other.accounts   && \
    entity   == other.entity
  end
end
end
