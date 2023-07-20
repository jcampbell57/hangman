# frozen_string_literal: true

# hangman console game game logic
class Game
  require 'yaml'

  attr_accessor :word_key, :correct_guesses, :incorrect_guesses, :guess_count

  def initialize(incorrect_guesses = [], guess_count = 7, correct_guesses = [], word_key = nil)
    self.incorrect_guesses = incorrect_guesses
    self.guess_count = guess_count
    self.correct_guesses = correct_guesses
    self.word_key = word_key.nil? ? randomize_key : word_key
    prompt_guess
  end

  # game initialization methods

  def randomize_key
    dictionary = []
    words = File.readlines('dictionary.txt')
    words.each { |word| dictionary << word.chomp if word.length.between?(5, 12) }
    self.word_key = dictionary.sample.split('')
    word_key.size.times { correct_guesses << '_' }
    word_key
  end

  # game save methods

  def save_game
    Dir.mkdir('saves') unless Dir.exist?('saves')
    save_array = [incorrect_guesses, guess_count, correct_guesses, word_key]
    save_info = YAML.dump(save_array)
    timestamp = Time.new.to_s[0..18]
    filename = "saves/#{timestamp}.yaml"
    File.open(filename, 'w') do |file|
      file.puts save_info
    end
    puts 'Your game has been saved.'
    exit
  end

  def load_game
    # p YAML.safe_load(save_info)
    # Game.new(YAML.safe_load(YAML.dump(to_s)))
  end

  # game loop methods

  def prompt_guess
    puts "Incorrect guesses: #{incorrect_guesses.join(' ')}"
    puts "Incorrect guesses remaining: #{guess_count}"
    puts "#{correct_guesses.join(' ')}"
    print "Guess a letter or type 'save' to save: "
    validate_guess(gets.chomp)
    prompt_guess
  end

  def validate_guess(input)
    if input.length == 1 && input.downcase.match?(/[a-z]/)
      if incorrect_guesses.any? { |l| l == input } || correct_guesses.any? { |l| l == input }
        print 'You have already guessed that letter, guess again: '
        validate_guess(gets.chomp)
      else
        process_guess(input)
      end
    elsif input.downcase == 'save'
      save_game
    else
      print 'Input your guess as a single letter: '
      validate_guess(gets.chomp)
    end
  end

  def process_guess(input)
    if word_key.any? { |l| l == input }
      puts 'Good guess!'
      word_key.each_with_index do |letter, index|
        letter == input ? correct_guesses[index] = letter : next
      end
      end_game if word_key == correct_guesses
    else
      puts 'No luck!'
      end_game if (self.guess_count -= 1).zero?
      incorrect_guesses << input
    end
  end

  # end game methods

  def end_game
    if word_key == correct_guesses
      # puts "You win with #{guess_count} guesses remaining! Great job!"
      puts "You won after #{7 - guess_count} incorrect guesses!"
    elsif word_key != correct_guesses && guess_count.zero?
      puts 'You ran out of guesses!'
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
