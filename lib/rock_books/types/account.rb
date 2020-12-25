module RockBooks

  # The ChartOfAccount holds the set of all these accounts for the entity.
  class Account < Struct.new(:code, :type, :name)

    PERMITTED_CODE_CHAR_REGEX = /[\w\-\.]$/ # word chars (letters, numbers, underscores), hyphens, periods

    def validate_code(code)
      unless PERMITTED_CODE_CHAR_REGEX.match(code)
        raise "Code {#{code}} may only contain letters, numbers, underscores, hyphens, and periods."
      end
    end

    def initialize(code, type, name)
      validate_code(code)
      super
    end
  end
end