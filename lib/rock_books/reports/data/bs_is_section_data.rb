module RockBooks

BsIsSectionData = Struct.new(:type, :context, :journals_acct_totals)
class BsIsSectionData

  def fetch
    {
      acct_totals: totals,
      total: totals.map(&:last).sum.round(2)
    }
  end

  private def totals
    @totals ||= calc_section_acct_totals
  end

  private def calc_section_acct_totals
    codes  = context.chart_of_accounts.account_codes_of_type(type)
    totals = journals_acct_totals.select { |code, _amount| codes.include?(code) }
    need_to_reverse_sign = %i{liability equity income}.include?(type)
    if need_to_reverse_sign
      totals.keys.each { |code| totals[code] = -totals[code] }
    end
    totals
  end

end
end