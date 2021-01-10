require_relative 'report_context'


module RockBooks
  class IndexHtmlPage

    include TextReportHelper

    attr_reader :context, :data

    def initialize(report_context, metadata, run_options)
      @context = report_context
      @data = {
        metadata: metadata,
        journals: context.journals,
        chart_of_accounts: context.chart_of_accounts,
        run_options: run_options,
      }
    end

    def generate
      ErbHelper.render_hashes('html/index.html.erb', data, template_presentation_context)
    end
  end
end
