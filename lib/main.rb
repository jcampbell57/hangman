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
  File.open("saves/#{filename}", 'w') { |file| file.write YAML.dump(current_game) }
  puts "Your game, '#{filename}', has been saved."
end

def load_game
  puts 'load game here (main.rb)'
end

# cannot use Game.new.play and still be able to save, must be seperate
current_game = player_choice == '1' ? Game.new : load_game
current_game.play

save_game(current_game)
