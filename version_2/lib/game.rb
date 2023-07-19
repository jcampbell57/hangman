class Game
  attr_accessor :word_key, :correct_guesses, :incorrect_guesses, :guess_count

  def initialize
    self.incorrect_guesses = []
    self.guess_count = 7
    randomize_key
    prompt_guess
  end

  def randomize_key
    dictionary = []
    words = File.readlines('version_2/dictionary.txt')
    words.each { |word| dictionary << word.chomp if word.length.between?(5, 12) }
    self.word_key = dictionary.sample.split('')
    self.correct_guesses = []
    word_key.size.times { correct_guesses << '_' }
  end

  def prompt_guess
    self.guess_count -= 1
    puts "Incorrect guesses: #{incorrect_guesses}"
    puts 'Guesses remaining: '
    puts "#{correct_guesses.join(' ')}"
    print 'Guess a letter: '
    validate_guess(gets.chomp)
    prompt_guess
  end

  def validate_guess(input)
    return input if input.length == 1 && input.downcase.match?(/[a-z]/)

    print 'Input your guess as a single letter: '
    validate_guess(gets.chomp)
  end

  # end game methods

  def end_game
    if word_key == correct_guesses
      puts "You win with #{7 - guess_count} guesses remaining! Great job!"
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
