module RockBooks

class ReportContext < Struct.new(:chart_of_accounts, :journals, :page_width)

  def entity
    chart_of_accounts.entity
  end
end

end
