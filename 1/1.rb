DICTIONARY = {
  "one" => "1",
  "two" => "2",
  "three" => "3",
  "four" => "4",
  "five" => "5",
  "six" => "6",
  "seven" => "7",
  "eight" => "8",
  "nine" => "9",
}

def get_number(char)
  DICTIONARY.values.find { |number|  number == char }
end

def get_number_from_word(str)
  word = DICTIONARY.keys.find { |word| str.start_with?(word) }

  DICTIONARY[word]
end

def number_word_parse(line)
  [].tap do |numbers|
    (0 ... line.length).each do |i|
      number = get_number(line[i]) || get_number_from_word(line[i..])

      numbers << number if number
    end
  end
end

lines = File.readlines('input', chomp: true)

acc = 0

lines.each do |line|
  acc += number_word_parse(line)
          .then { |arr| p arr; [arr.first, arr.last] }
          .join
          .to_i
          .tap { |line| p "result", line }
end

p acc
