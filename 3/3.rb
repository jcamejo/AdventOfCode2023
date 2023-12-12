require "ostruct"
require "pry"


class EngineMap
  def initialize(input)
    @input = File.readlines(input, chomp: true)
  end

  attr_reader :engine_map

  def map_engine
    mapped_engine = []
    mapped_line = []
    prev_element = nil

    @input.each_with_index do |line, y|
      line.chars.each_with_index do |element, x|
        mapped_line << OpenStruct.new(
          x:,
          y:,
          element_type: element_type(element),
          element:,
          prev_element:,
        )
      end

      mapped_engine << mapped_line.compact
      mapped_line = []
    end

    @engine_map = mapped_engine
  end

  def element_type(element)
    return if element == '.'
    return "number" if element.match?(/\d/)

    "symbol"
  end

  def get_element(x, y)
    row = engine_map.fetch(y, nil)
    return unless row

    cell = row.fetch(x, nil)
    return unless cell

    cell
  end

  def get_number_element(x, y)
    element = get_element(x, y)

    return if element.nil?
    return if element.element_type != 'number'

    element
  end

  def get_symbol_element(x, y)
    element = get_element(x, y)

    return if element.nil?
    return if element.element_type != 'symbol'

    element
  end

  def includes_number?(numbers, new_number)
    return if new_number.nil?

    numbers.each do |number|
      return true if number[:coordinates].any? { |coordinates| new_number[:coordinates].include?(coordinates) }
    end

    false
  end

  def find_adjacent_numbers(symbol_element)
    numbers = []

    adjacent_digits = [
      get_number_element(symbol_element.x, symbol_element.y - 1),
      get_number_element(symbol_element.x - 1, symbol_element.y - 1),
      get_number_element(symbol_element.x - 1, symbol_element.y),
      get_number_element(symbol_element.x - 1, symbol_element.y + 1),
      get_number_element(symbol_element.x, symbol_element.y + 1),
      get_number_element(symbol_element.x + 1, symbol_element.y + 1),
      get_number_element(symbol_element.x + 1, symbol_element.y),
      get_number_element(symbol_element.x + 1, symbol_element.y - 1),
    ]
    adjacent_digits.compact.map do |number|
      built_number = build_number(number)
      numbers << built_number unless includes_number?(numbers, built_number)
    end

    numbers.map{|number| number[:number]}
  end

  def find_adjacent_symbols(element)
    symbols = []
    symbols << get_symbol_element(element.x, element.y - 1)
    symbols << get_symbol_element(element.x - 1, element.y - 1)
    symbols << get_symbol_element(element.x - 1, element.y)
    symbols << get_symbol_element(element.x - 1, element.y + 1)
    symbols << get_symbol_element(element.x, element.y + 1)
    symbols << get_symbol_element(element.x + 1, element.y + 1)
    symbols << get_symbol_element(element.x + 1, element.y)
    symbols << get_symbol_element(element.x + 1, element.y - 1)

    symbols.compact
  end

  def get_gear_ratios
    wheels = engine_map
              .map { |line| line.select { |coord| coord.element == '*' }}
              .flatten
              .map { |wheel| { wheel:, adjacent_numbers: find_adjacent_numbers(wheel) } }
              .select { |wheel| wheel[:adjacent_numbers].length == 2 }
              .map do |wheel|
                wheel[:number_ratio] = wheel[:adjacent_numbers].inject(:*)
                wheel
              end

    number_ratio = wheels.inject(0) do |sum, wheel|
      sum += wheel[:number_ratio]
    end

    number_ratio
  end

  def build_number(element)
    trailing_numbers = []
    leading_numbers = []
    trailing_x = element.x + 1
    leading_x = element.x - 1

    trailing_element = get_number_element(trailing_x, element.y)
    leading_element = get_number_element(leading_x, element.y)

    while(trailing_element)
      trailing_numbers.push(trailing_element)
      trailing_x += 1
      trailing_element = get_number_element(trailing_x, element.y)
    end

    while(leading_element)
      leading_numbers.unshift(leading_element)
      leading_x -= 1
      leading_element = get_number_element(leading_x, element.y)
    end

    number_collection = [leading_numbers, element, trailing_numbers].flatten

    number = number_collection.map(&:element).join.to_i
    coordinates = number_collection.map { |number| [number.x, number.y] }

    { number:, coordinates: }
  end

  def get_number_template
    {
      digits: [],
      adjacent_symbols: []
    }
  end
end


engine_mapper = EngineMap.new('input')
engine_mapper.map_engine
p engine_mapper.get_gear_ratios
