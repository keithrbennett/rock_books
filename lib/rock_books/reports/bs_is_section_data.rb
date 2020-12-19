module RockBooks

BsIsSectionData = Struct.new(:type, :context, :all_acct_totals)
class BsIsSectionData

    def acct_codes
      @acct_codes ||= context.chart_of_accounts.account_codes_of_type(type)
    end

    def acct_totals
      all_acct_totals.select { |code, _amount| acct_codes.include?(code) }
    end

    def need_to_reverse_sign
      %i{liability equity}.include?(type)
    end

    def section_total
      acct_totals.map(&:last).sum.round(2)
    end

    def call
      if need_to_reverse_sign
        acct_totals.each { |code, amount| acct_totals[code] = -amount }
      end

      {
          acct_totals: acct_totals,
          total: section_total
      }
    end
  end
end