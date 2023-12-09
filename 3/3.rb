require "ostruct"

lines = File.readlines('input', chomp: true)

def element_type(element)
  return if element == '.'
  return "number" if element.match?(/\d/)

  "symbol"
end

def map_engine(lines)
  mapped_engine = []
  mapped_line = []
  prev_element = nil

  lines.each_with_index do |line, y|
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

  [mapped_engine, mapped_engine.flatten]
end

def get_element(engine_map, x, y)
  engine_map.find { |element| element.x == x && element.y == y }
end

def get_number_element(engine_map, x, y)
  element = get_element(engine_map, x, y)

  return if element.nil?
  return if element.element_type != 'number'

  element
end

def get_symbol_element(engine_map, x, y)
  element = get_element(engine_map, x, y)

  return if element.nil?
  return if element.element_type != 'symbol'

  element
end

def find_adjacent_numbers(engine_map, symbol_element)
  numbers = []
  numbers << get_number_element(engine_map, symbol_element.x, symbol_element.y - 1)
  numbers << get_number_element(engine_map, symbol_element.x - 1, symbol_element.y - 1)
  numbers << get_number_element(engine_map, symbol_element.x - 1, symbol_element.y)
  numbers << get_number_element(engine_map, symbol_element.x - 1, symbol_element.y - 1)
  numbers << get_number_element(engine_map, symbol_element.x, symbol_element.y + 1)
  numbers << get_number_element(engine_map, symbol_element.x + 1, symbol_element.y + 1)
  numbers << get_number_element(engine_map, symbol_element.x + 1, symbol_element.y)
  numbers << get_number_element(engine_map, symbol_element.x + 1, symbol_element.y - 1)

  numbers.compact
end

def find_adjacent_symbols(engine_map, element)
  symbols = []
  symbols << get_symbol_element(engine_map, element.x, element.y - 1)
  symbols << get_symbol_element(engine_map, element.x - 1, element.y - 1)
  symbols << get_symbol_element(engine_map, element.x - 1, element.y)
  symbols << get_symbol_element(engine_map, element.x - 1, element.y + 1)
  symbols << get_symbol_element(engine_map, element.x, element.y + 1)
  symbols << get_symbol_element(engine_map, element.x + 1, element.y + 1)
  symbols << get_symbol_element(engine_map, element.x + 1, element.y)
  symbols << get_symbol_element(engine_map, element.x + 1, element.y - 1)

  symbols.compact
end

def adjacent_symbol?(engine_map, element)
  find_adjacent_symbols(engine_map, element).any?
end

def build_number(engine_map, element_number)
  leading_numbers = []
  trailing_numbers = []

  trailing_number = get_number_element(engine_map, element_number.x + 1, element_number.y)
  while trailing_number
    trailing_numbers.push(trailing_number)

    trailing_number = get_number_element(engine_map, trailing_number.x + 1, element_number.y)
  end

  leading_number = get_number_element(engine_map, element_number.x - 1, element_number.y)
  while leading_number
    leading_numbers.unshift(leading_number)

    leading_number = get_number_element(engine_map, leading_number.x - 1, element_number.y)
  end

  [leading_numbers.compact, element_number, trailing_numbers.compact]
    .flatten
    .map(&:element)
    .join
    .to_i
end

engine_map, flat_engine = map_engine(lines)

numbers_with_symbols = []
possible_number = []
adjacent_symbol = false
symbols = flat_engine.select do |element|
  element.element_type == 'symbol'
end

engine_map.each_with_index do |line, index|
  per_line = []
  possible_number = []

  line.each_with_index do |element, i|
    if element.element_type == "number"
      possible_number << element
      symbols = find_adjacent_symbols(flat_engine, element)
      adjacent_symbol = true if symbols.any?
    end

    if element.element_type != "number" && !adjacent_symbol && possible_number.any?
      possible_number = []
    end

    if (element.element_type != "number" && adjacent_symbol) || (adjacent_symbol && line.length == i + 1)
      number = possible_number.map(&:element).join.to_i
      adjacent_symbol = false
      numbers_with_symbols << possible_number.map(&:element).join.to_i
      possible_number = []
    end
  end
end

p "total", numbers_with_symbols.inject(:+)
