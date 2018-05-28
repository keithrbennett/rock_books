require_relative 'error'

module RockBooks

  class AccountType < Struct.new(:symbol, :singular_name, :plural_name)

    ASSET         = self.new(:asset,         'Asset',         'Assets')
    LIABILITY     = self.new(:liability,     'Liability',     'Liabilities')
    OWNERS_EQUITY = self.new(:owners_equity, 'Owners Equity', 'Owners Equity')
    INCOME        = self.new(:income,        'Income',        'Income')
    EXPENSE       = self.new(:expense,       'Expense',       'Expenses')

    ALL_TYPES = [ASSET, LIABILITY, OWNERS_EQUITY, INCOME, EXPENSE]

    TYPE_HASH = {
        'A' => ASSET,
        'L' => LIABILITY,
        'O' => OWNERS_EQUITY,
        'I' => INCOME,
        'E' => EXPENSE
    }

    # Converts strings
    def self.to_type(string)
      type = TYPE_HASH[string[0].upcase]
      if type.nil?
        raise Error.new("Account type of #{string} not valid. " +
            "Must be one of #{TYPE_HASH.keys} (#{ALL_TYPES.map(&:singular_name)})")
      end
      type
    end
  end
end