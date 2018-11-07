module RockBooks

  module Samples

    module_function

    def chart_of_accounts
      ChartOfAccounts.from_string(
        <<~HEREDOC
          101 A Cash in Bank
          141 A Computer Equipment
          142 A Computer Equipment - Accumulated Depreciation
          201 L Accounts Payable
          301 O Owners Equity
          401 I Sales
          701 E Office Supplies
          702 E Rent
          703 E Professional Fees
        HEREDOC
      )
    end
  end
end