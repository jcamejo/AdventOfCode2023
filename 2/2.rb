RED = 0
BLUE = 2
GREEN = 1

MAX_CUBES =  {
  'red' => 12,
  'green' => 13,
  'blue' =>  14
}

lines = File.readlines('input', chomp: true)

def process_game(line)
  subset_str = line.split(':').last
  cube_rolls = subset_str
    .split(';')
    .map { |game| game.split(',').map(&:strip) }
    .map {|game| process_result(game) }
end

def get_cube_result(game, color)
  color_index = game.find_index do |cube_throw|
    cube_throw.include?(color)
  end

  return 0 unless color_index

  game[color_index].split(' ').first.to_i
end

def process_result(game)
  result = Array.new(3)

  result[RED] = get_cube_result(game, 'red')
  result[GREEN] = get_cube_result(game, 'green')
  result[BLUE] = get_cube_result(game, 'blue')

  result
end

def valid_game?(game_throw)
  game_throw.all? { |game| game[RED] <= 12 && game[BLUE] <= 14 && game[GREEN] <= 13 }
end

def get_mininum_playable_cubes(game)
  minimun_reds = game.map { |gm| gm[RED] }.max
  minimun_blues = game.map { |gm| gm[BLUE] }.max
  minimun_greens = game.map { |gm| gm[GREEN] }.max

  [minimun_reds, minimun_greens, minimun_blues]
end

valid_games = []
valid_ids = []
games = []

lines.each_with_index do |line, index|
  id, processed_game = [index + 1, process_game(line)]
  valid_games << processed_game if valid_game?(processed_game)
  valid_ids << id if valid_game?(processed_game)

  games << processed_game
end

minimun_cubes = games.map do |game|
  get_mininum_playable_cubes(game).inject(1) do |mult, n|
    return mult if n == 0
    mult * n
  end
end

p "valid ids Part 1", valid_ids.inject(:+)

p "minimun_cubes Part 2", minimun_cubes.inject(:+)
