require 'forwardable'

module RockBooks

class ReportContext
  extend Forwardable

  attr_reader :book_set

  def_delegator :book_set, :chart_of_accounts
  def_delegator :book_set, :extra_output_line
  def_delegator :book_set, :journals

  def initialize(book_set)
    @book_set = book_set
  end

  def page_width
    80
  end

  def entity
    chart_of_accounts.entity
  end
end
end
