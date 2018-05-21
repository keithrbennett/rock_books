module RockBooks

# Contains code used by both General Journal and regular Journal classes
module JournalCommon

  module_function

  def convert_alternate_amounts_to_floats(tokens)
    (1...tokens.size).step(2) do |amount_index|
      tokens[amount_index] = Float(tokens[amount_index])
    end
  end


  def parse_line(line)
    case line.strip
    when /^@doc_type:/
      @doc_type = line.split(/^@doc_type:/).last.strip
    when  /^@account_code:/
      @account_code = line.split(/^@account_code:/).last.strip
      unless chart_of_accounts.include?(@account_code)
        raise AccountNotFoundError.new(@account_code)
      end
      if @debit_or_credit.nil?  # has not yet been explicitly specified
        @debit_or_credit = chart_of_accounts.debit_or_credit_for_code(account_code)
      end
    when /^@title:/
      @title = line.split(/^@title:/).last.strip
    when /^@date_prefix:/
      @date_prefix = line.split(/^@date_prefix:/).last.strip
    when /^@debit_or_credit:/
      data = line.split(/^@debit_or_credit:/).last.strip
      @debit_or_credit = data.to_sym
    when /^$/
      # ignore empty line
    when /^#/
      # ignore comment line
    when /^\d/  # a date/acct/amount line starting with a number
      parse_main_transaction_line(line)
    else # Text line(s) to be attached to the most recently parsed transaction
      entries.last.description ||= ''
      entries.last.description << line << "\n"
    end
  end

end
end
