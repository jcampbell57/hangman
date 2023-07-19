class Game
  attr_accessor :word_key, :correct_guesses, :incorrect_guesses, :guess_count

  def initialize
    self.incorrect_guesses = []
    self.guess_count = 7
    randomize_key
    prompt_guess
  end

  # game initialization methods

  def randomize_key
    dictionary = []
    words = File.readlines('version_2/dictionary.txt')
    words.each { |word| dictionary << word.chomp if word.length.between?(5, 12) }
    self.word_key = dictionary.sample.split('')
    self.correct_guesses = []
    word_key.size.times { correct_guesses << '_' }
  end

  # game loop methods

  def prompt_guess
    puts "Incorrect guesses: #{incorrect_guesses.join(' ')}"
    puts "Incorrect guesses remaining: #{guess_count}"
    puts "#{correct_guesses.join(' ')}"
    print 'Guess a letter: '
    validate_guess(gets.chomp)
    prompt_guess
  end

  def validate_guess(input)
    if input.length == 1 && input.downcase.match?(/[a-z]/)
      process_guess(input)
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
      (guess_count - 1).zero? ? end_game : self.guess_count -= 1
      incorrect_guesses << input
    end
  end

  # end game methods

  def end_game
    if word_key == correct_guesses
      puts "You win with #{7 - guess_count} incorrect guesses! Great job!"
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
