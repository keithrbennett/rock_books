module RockBooks

  module Samples

    module_function

    def chart_of_accounts
      ChartOfAccounts.new(
        <<~HEREDOC
          101 D Cash in Bank
          201 C Accounts Payable
          301 C Owners Equity
          401 C Sales
          701 D Office Supplies
          702 D Rent
          703 D Professional Fees
        HEREDOC
      )
    end
  end
end