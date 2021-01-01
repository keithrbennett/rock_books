require_relative 'report_context'


module RockBooks
class ReceiptsReport

  include Reporter

  attr_reader :context, :missing, :existing, :unused


  def initialize(report_context, missing, existing, unused)
    @context = report_context
    @missing = missing
    @existing = existing
    @unused = unused
  end


  def generate
    data = {
      missing: missing,
      unused: unused,
      existing: existing
    }
    ErbHelper.render_hashes('text/receipts_report.txt.erb', data, template_presentation_context)
  end
end
end