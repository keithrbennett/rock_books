module RockBooks

BsIsSectionData = Struct.new(:type, :context, :all_acct_totals)
class BsIsSectionData

    def acct_codes
      @acct_codes ||= context.chart_of_accounts.account_codes_of_type(type)
    end

    def acct_totals
      @acct_totals ||= all_acct_totals.select { |code, _amount| acct_codes.include?(code) }
    end

    def need_to_reverse_sign
      %i{liability equity income}.include?(type)
    end

    def section_total
      acct_totals.map(&:last).sum.round(2)
    end

    def call
      totals = acct_totals
      if need_to_reverse_sign
        totals.keys.each { |code| totals[code] = -totals[code] }
      end

      {
          acct_totals: totals,
          total: section_total
      }
    end
  end
end