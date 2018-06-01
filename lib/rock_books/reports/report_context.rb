module RockBooks

class ReportContext < Struct.new(
    :entity_name,
    :chart_of_accounts,
    :journals,
    :start_date,
    :end_date,
    :page_width)

end

end
