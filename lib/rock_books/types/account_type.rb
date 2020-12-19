require_relative '../errors/error'

module RockBooks

  class AccountType < Struct.new(:symbol, :singular_name, :plural_name)

    ASSET         = self.new(:asset,      'Asset',      'Assets')
    LIABILITY     = self.new(:liability,  'Liability',  'Liabilities')
    EQUITY        = self.new(:equity,     'Equity',     'Equity')
    INCOME        = self.new(:income,     'Income',     'Income')
    EXPENSE       = self.new(:expense,    'Expense',    'Expenses')

    ALL_TYPES = [ASSET, LIABILITY, EQUITY, INCOME, EXPENSE]

    LETTER_TO_TYPE = {
        'A' => ASSET,
        'L' => LIABILITY,
        'O' => EQUITY,
        'I' => INCOME,
        'E' => EXPENSE
    }

    SYMBOL_TO_TYPE = {
        :asset => ASSET,
        :liability => LIABILITY,
        :equity => EQUITY,
        :income => INCOME,
        :expense => EXPENSE
    }

    # Converts type upper case letter representation to a type object (e.g. 'A' => ASSET)
    def self.letter_to_type(string)
      LETTER_TO_TYPE[string[0].upcase]
    end

    def self.symbol_to_type(symbol)
      SYMBOL_TO_TYPE[symbol]
    end
  end
end