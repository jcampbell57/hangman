# frozen_string_literal: true

require 'colorize'

# Hangman logic
class Game
  attr_accessor :secret_word, :user_guess, :previous_guesses, :save, :over

  def initialize
    @incorrect_guesses = 0
    @lives = 6
    @user_guess = []
    @previous_guesses = []
    @save = false
    @over = false
  end

  def choose_word
    word_bank = File.readlines('google-10000-english-no-swears.txt') if File.exist? 'google-10000-english-no-swears.txt'
    word_bank.delete_if { |word| word.chomp.length < 5 || word.chomp.length > 12 }
    @secret_word = word_bank.sample.chomp
    @secret_word.length.times { @user_guess << '_' }
    puts "a random word with #{@secret_word.length} letters has been chosen."
  end

  def player_input
    print "Guess a letter or input 'save' to save the game: "
    user_input = gets.chomp.downcase
    return user_input if user_input.match?(/^[a-z]{1}$/) # || user_input == 'save'
    return 'save' if user_input == 'save'

    # when user guess is invalid:
    puts 'Invalid input!'.colorize(:light_yellow)
    player_input
  end

  def process_input(input)
    if previous_guesses.include?(input.colorize(:light_red)) ||
       previous_guesses.include?(input.colorize(:light_green))
      puts 'You have already guessed that letter!'.colorize(:light_yellow)
      prompt_player
    elsif input == 'save'
      @save = true
    elsif @secret_word.include?("#{input}")
      process_correct_guess(input)
    else
      process_incorrect_guess(input)
    end

    if @incorrect_guesses == @lives || user_guess.join == secret_word
      puts 'end 1'
      end_game
    elsif save == true
      # return to main.rb to save
    else
      prompt_player
    end
  end

  def process_correct_guess(input)
    puts 'Good guess!'.colorize(:green)
    previous_guesses << input.colorize(:light_green)
    secret_word.split('').each_with_index do |letter, index|
      if letter == input
        user_guess[index] = input
      end
    end
    # end_game unless user_guess.include?('_')
    # do not prompt if playing again
    # prompt_player unless @incorrect_guesses == @lives || user_guess.join == secret_word
  end

  def process_incorrect_guess(input)
    puts 'No luck!'.colorize(:light_red)
    @incorrect_guesses += 1
    previous_guesses << input.colorize(:light_red)
    # prompt_player
  end

  def prompt_player
    puts 'end 2'
    end_game if @incorrect_guesses == @lives || user_guess.join == secret_word

    puts "Previous guesses: #{@previous_guesses.join(' ')}" if @previous_guesses.empty? == false
    puts "Incorrect guesses remaining: #{@lives - @incorrect_guesses}"
    puts user_guess.join(' ')
    user_input = player_input
    process_input(user_input)
  end

  # this is buggy when going to save game during another round
  def play_again_prompt
    print 'Would you like to play again? [y/n]: '
    player_response = gets.chomp.downcase
    if player_response == 'y'
      # return to main.rb to start new game.
    else
      # exit
      puts 'Thanks for playing!'
      # @over = true
      exit
    end
  end

  def play
    choose_word
    prompt_player
  end

  def end_game
    if @incorrect_guesses == @lives
      puts 'Better luck next time!'.colorize(:light_red)
      puts "The word was: #{secret_word}"
    else
      puts 'Congratulations, you guessed the word!'.colorize(:light_green)
      p @secret_word
    end
    play_again_prompt
  end
end
