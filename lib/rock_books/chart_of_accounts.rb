require_relative 'error'

module RockBooks
class ChartOfAccounts

  class Account < Struct.new(:code, :debit_or_credit, :name); end

  attr_reader :doc_type, :title, :accounts


  def initialize(input_string)
    @accounts = []
    lines = input_string.split("\n")
    lines.each { |line| parse_line(line) }
  end


  def parse_line(line)
    case line.strip
    when /^@doc_type:/
      @doc_type = line.split('doc_type:').last.strip
    when /^@title:/
      @title = line.split('title:').last.strip
    when /^@debit_or_credit:/
      @debit_or_credit = line.split('debit_or_credit:').last.strip
    when /^$/
      # ignore empty line
    when /^#/
      # ignore comment line
    else
      # this is an account line in the form: 101 D First National City Bank
      # The regex below gets everything before the first whitespace in token 1, and the rest in token 2.
      matcher = line.match(/^(\S+)\s+(.*)$/)
      code = matcher[1]
      rest = matcher[2]

      matcher = rest.match(/^(\S+)\s+(.*)$/)
      debit_or_credit_token = matcher[1]
      name = matcher[2]

      debit_or_credit = case debit_or_credit_token[0].upcase
        when 'D'
          :debit
        when 'C'
          :credit
        else
          raise Error.new("Debit or credit type must begin with d, D, c, or C. Was #{debit_or_credit_token}.")
        end

      accounts << Account.new(code, debit_or_credit, name)
    end
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
    format_string = "%#{code_width}s  %s\n"
    accounts.each { |a| result << format_string % [a.code, a.name] }

    result
  end


  def account_for_code(code)
    accounts.detect { |a| a.code == code }
  end


  def name_for_code(code)
    found = account_for_code(code)
    found ? found.name : nil
  end


  def debit_or_credit_for_code(code)
    found = account_for_code(code)
    found ? found.debit_or_credit.to_sym : nil
  end


  def max_account_code_length
    @max_account_code_length ||= accounts.map { |a| a.code.length }.max
  end
end
end
