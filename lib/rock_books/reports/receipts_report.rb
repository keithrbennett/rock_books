require_relative 'report_context'


module RockBooks
class ReceiptsReport

  include Reporter

  attr_reader :context, :data

  def initialize(report_context, data)
    @context = report_context
    @data = data
  end


  def generate
    ErbHelper.render_hashes('text/receipts_report.txt.erb', data, template_presentation_context)
  end
end
end