# frozen_string_literal: true

require_relative 'colors'

# hangman console game logic
class Game
  require 'yaml'

  attr_accessor :word_key, :player_guess, :previous_guesses, :guess_count

  DEFAULT_GUESSES = 6

  def initialize
    self.previous_guesses = []
    self.guess_count = DEFAULT_GUESSES
    self.player_guess = []
    self.word_key = randomize_key
    start_game
  end

  # game initialization methods

  def randomize_key
    dictionary = []
    words = File.readlines('dictionary.txt')
    words.each { |word| dictionary << word.chomp if word.length.between?(5, 12) }
    self.word_key = dictionary.sample.split('')
    word_key.size.times { player_guess << '_' }
    word_key
  end

  def start_game
    puts 'Lets play Hangman in the console!'
    if Dir.exist?('saves')
      puts '- [1] for new game'
      puts '- [2] to load game'
      print 'New game or saved game: '
      response = validate_game_selection(gets.chomp.to_i)
      response == 1 ? prompt_guess : load_game
    else
      prompt_guess
    end
  end

  def validate_game_selection(input)
    if input != 1 && input != 2
      print "Input '1' for new game or '2' for saved game: "
      validate_game_selection(gets.chomp.to_i)
    end
    input
  end

  # game save methods

  def save_game
    Dir.mkdir('saves') unless Dir.exist?('saves')
    timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    filename = "saves/#{timestamp}.yaml"
    File.open(filename, 'w') { |f| YAML.dump([] << self, f) }
    puts 'Your game has been saved.'
    exit
  end

  def load_game
    puts '- [#] time when game was saved'
    saved_games = Dir.glob('saves/*.*')
    saved_games.each_with_index do |filename, index|
      puts "- [#{index + 1}] #{filename.delete_prefix('saves/').delete_suffix('.yaml')}"
    end
    print 'Enter the # of the game you would like to play: '
    validate_game_choice(gets.chomp, saved_games)
  end

  def validate_game_choice(input, saved_games)
    if input.split('').all? { |character| character.match(/[0-9]/) } && saved_games[input.to_i - 1].nil? == false
      process_game_choice(input.to_i - 1, saved_games)
    else
      print 'Game does not exist, choose again: '.bold.brown
      validate_game_choice(gets.chomp, saved_games)
    end
  end

  def process_game_choice(input, saved_games)
    yaml = YAML.safe_load(
      File.read(saved_games[input]),
      permitted_classes: [Game]
    )
    self.previous_guesses = yaml[0].previous_guesses
    self.guess_count = yaml[0].guess_count
    self.player_guess = yaml[0].player_guess
    self.word_key = yaml[0].word_key
    File.delete(saved_games[input])
    prompt_guess
  end

  # game loop methods

  def prompt_guess
    if guess_count < DEFAULT_GUESSES
      puts "Previous guesses: #{previous_guesses.join(' ')}"
      puts "Incorrect guesses remaining: #{guess_count}"
    end
    puts "#{player_guess.join(' ')}"
    print "Guess a letter or type 'save' to save: "
    validate_guess(gets.chomp)
    prompt_guess
  end

  def validate_guess(input)
    if input.length == 1 && input.downcase.match?(/[a-z]/)
      if previous_guesses.any? { |l| l == input.bold.red || l == input.bold.green }
        puts 'You have already guessed that letter!'.bold.brown
        print "Guess a letter or type 'save' to save: "
        validate_guess(gets.chomp)
      else
        process_guess(input)
      end
    elsif input.downcase == 'save'
      save_game
    else
      puts 'Invalid input! Input your guess as a single letter.'.bold.brown
      print "Guess a letter or type 'save' to save: "
      validate_guess(gets.chomp)
    end
  end

  def process_guess(input)
    if word_key.any? { |l| l == input }
      puts 'Good guess!'.bold.green
      previous_guesses << input.bold.green
      word_key.each_with_index do |letter, index|
        letter == input ? player_guess[index] = letter : next
      end
      end_game if word_key == player_guess
    else
      puts 'No luck!'.bold.red
      end_game if (self.guess_count -= 1).zero?
      previous_guesses << input.bold.red
    end
  end

  # end game methods

  def end_game
    if word_key == player_guess
      puts 'Congratulations, you guessed the word!'.bold.green
      p word_key.join
    elsif word_key != player_guess && guess_count.zero?
      puts 'You ran out of guesses!'.bold.red
      puts "The word was: #{word_key.join}"
    else
      puts "I'm not sure how you lost!"
    end
    prompt_new_game
  end

  def prompt_new_game
    print 'Would you like to play again? [y/n]: '
    user_input = validate_new_game_input(gets.chomp)
    user_input == 'y' ? Game.new : exit
  end

  def validate_new_game_input(user_input)
    return user_input.downcase if user_input.downcase == 'y' || user_input.downcase == 'n'

    puts "Enter 'y' for a new round or 'n' to exit: "
    validate_new_game_input(gets.chomp)
  end
end
