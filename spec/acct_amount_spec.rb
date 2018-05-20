require_relative '../lib/rock_books/journal'

module RockBooks

  RSpec.describe RockBooks::AcctAmount do

    it 'can output and parse YAML correctly' do
      code = '333'; amount = 1000; date = Date.iso8601('2018-05-16')
      obj = AcctAmount.new(date, code, amount)

      parsed_obj = YAML.load(obj.to_yaml)

      expect(parsed_obj.date).to eq(date)
      expect(parsed_obj.code).to eq(code)
      expect(parsed_obj.amount).to eq(amount)
    end

    # it 'can output and parse JSON correctly' do
    #   code = '333'; amount = 1000; date = Date.iso8601('2018-05-16')
    #   obj = AcctAmount.new(date, code, amount)
    #   ap obj; sleep 2
    #   parsed_obj = JSON.parse(obj.to_json, object_class: AcctAmount)
    #   ap parsed_obj.class
    #   expect(parsed_obj.code).to eq(code)
    #   expect(parsed_obj.amount).to eq(amount)
    #   expect(parsed_obj.date).to eq(date)
    # end

  end
end
