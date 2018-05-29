module RockBooks

  # The ChartOfAccount holds the set of all these accounts for the entity.
  class Account < Struct.new(:code, :type, :name)
  end

end