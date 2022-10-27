# frozen_string_literal: true

require_relative 'game'
require 'yaml'

private

def player_choice
  puts 'New game or load game?:'
  puts '- [1] New game'
  puts '- [2] Load game'
  print "Input '1' or '2': "
  input = gets.chomp
  return input if input.match?(/^[1-2]{1}$/)

  # if input is invalid:
  puts 'Invalid input!'.colorize(:light_yellow)
  player_choice
end

def filename_prompt
  print 'Name your save: '
  name = gets.chomp
  return name if name.match?(/^[0-9a-zA-Z_\- ]+$/)

  # if filename is not valid:
  puts 'Invalid name!'
  filename_prompt
end

def save_game(current_game)
  filename = filename_prompt
  Dir.mkdir 'saves' unless Dir.exist? 'saves'
  File.open("saves/#{filename}.yaml", 'w') { |file| file.write YAML.dump(current_game) }
  puts "Your game, '#{filename}', has been saved."
end

def choose_game
  saved_games = Dir.glob('saves/*')
  Dir.glob('saves/*').each_with_index do |file, index|
    puts "#{index + 1}. #{file[(file.index('/') + 1)...(file.index('.'))]}"
  end
  print 'Input the number of a game from above: '
  selection = gets.chomp

  unless selection.to_i.to_s == selection
    puts 'Invalid selection, please input a number.'.colorize(:light_yellow)
    choose_game
  end

  return saved_games[selection.to_i - 1] unless saved_games[selection.to_i - 1].nil?

  # if selection is invalid:
  puts 'Invalid selection'.colorize(:light_yellow)
  choose_game
end

def load_game
  user_selection = choose_game
  YAML.safe_load(
    File.read(user_selection),
    permitted_classes: [Game]
  )
end

# cannot use Game.new.play and still be able to save, must be seperate
current_game = if Dir.glob('saves/*').empty?
                 Game.new
               else
                 player_choice == '1' ? Game.new : load_game
               end
current_game.play

save_game(current_game)
