module RockBooks
module Reporter

  module_function

  def banner_line
    @banner_line ||= '-' * page_width
  end

  def center(string)
    (' ' * ((page_width - string.length) / 2)) + string
  end
end
end

