class Game
  attr_accessor :word_key, :correct_guesses, :incorrect_guesses

  def initialize
    self.incorrect_guesses = []
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
    puts "Incorrect guesses: #{incorrect_guesses}"
    puts 'Incorrect guesses remaining: '
    puts "#{correct_guesses}"
    print 'Guess a letter: '
    validate_guess(gets.chomp)
    prompt_guess
  end

  def validate_guess(input)
    input
  end
end
