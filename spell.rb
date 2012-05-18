#!/usr/bin/ruby
#
# simple spell checker library, as a small challenge
#
# (C) 2012, Carlos Puchol <cpg at rocketmail dot com>
#
# features:
#  - if the word is in the dictionary, returns that one first
#  - type the word crank to get it it start cranking words and checking them
#    it will generate 1000 words, check them, then print a dot
#    it will print a ! if it cannot march the generated word
#  - start with ./spell.rb -g to generate words from the dictionary
#  - start with ./spell.rb -c to consume lines with words from stdin and print the resulting match
#
# this program entry point has three modes of operation:
#  - generate words (with -g)
#  - consume and check words from stdin (with -c)
#  - interactive. type the word crank to start generating and checking forver

# spell checker class on which the program is based
class Spell

	# dictionary with buckets of words, one per letter in the alphabet
	attr_reader :dictionary

	def initialize(wordfile = "/usr/share/dict/words")
		@dictionary = { }
		IO.readlines(wordfile).map do |w|
			word = w.chomp
			fc = word[0,1].downcase
			@dictionary[fc] = [] unless @dictionary[fc]
			# save the regexp for the word, along with the word, in the dict
			@dictionary[fc] << [make_regexp(word), word]
		end
	end

	# check the word and find the closest spelling in the dict
	def check(word)
		result = find_word(word)
		return "NO SUGGESTION" if result.empty?
		# if the word is in the results, just return it
		return word if result.include? word
		matches = result.grep(/^#{word}$/i)
		# if the word is there with swapped caps, return that
		return matches.first if matches.size > 0
		# else return the first one
		# FIXME: simple selection of a "good" match. must improve it!
		result.first
	end

	# generate a bunch of words mangled from the dictionary
	def generate(num = 100)
		results = []
		1.upto(num) { results << mangle_word(pick_a_word) }
		results
	end

	#private

	# pick a word
	def pick_a_word
		bucket = @dictionary[@dictionary.keys[rand @dictionary.size]]
		pair = bucket[rand bucket.size]
		pair.last
	end

	def mangle_word(word)
		# FIXME: not all possible combinations here, e.g. twist the vowel and repeat
		word.split(//).map do |letter|
			case rand 4
			when 0
				# leave as is
				letter
			when 1
				# mangle case
				letter.swapcase
			when 2
				# repeat the letter some random amount of times
				([letter] * (rand(15)+1)).join
			else
				letter =~ /[aeiou]/ ? "aeiouAEIOU"[rand(10), 1] : letter
			end
		end.join
	end

	# do the hard work of trying to find the given word
	def find_word(word)
		fc = word[0,1].downcase
		# check if it's a vowel
		if fc =~ /[aeiou]/
			# if so, then check in each bucket
			"aeiou".split(//).map do |letter|
				find_matches(@dictionary[letter], word)
			end.flatten
		else
			# else we do the search directly
			find_matches(@dictionary[fc], word)
		end
	end

	# find the maches of a word in a dictionary bucket
	def find_matches(bucket, word)
		matches = bucket.map do |exp, match|
			word =~ exp ? match : nil
		end
		matches.compact
	end

	# make a regular expression for the string we are trying to match
	def make_regexp(word)
		exps = word.scan(/./).map do |c|
			if c =~ /[aeiou]/i
				"[aeiou]+"
			else
				"#{c}+"
			end
		end
		# make it a regular expression and ignore the case, also match the whole expression
		Regexp.new("^#{exps.join}$", Regexp::IGNORECASE)
	end
end

def generate_forever(num = 1000)
	spell = Spell.new
	while true
		words = spell.generate(num)
		words.each { |word| puts word }
		$stdout.flush
	end
end

def check_forever
	spell = Spell.new
	while true
		input = readline.chomp
		match = spell.check(input)
		puts "BEST MATCH: #{match}\t\tINPUT: #{input}"
	end
end

def generate_forever_interactive(checker, num = 100)
	while true
		words = checker.generate(num)
		begin
			words.each do |word|
				result = checker.check word
				raise "problem!" if result == "NO SUGGESTION"
			end
			print '.'
		rescue
			print "!"
		end
		$stdout.flush
	end
end

# interactive input loop
def interactive_loop
	print "Reading system dictionary ..."
	$stdout.flush
	spell = Spell.new
	puts " done."
	begin
		while true
			print "> "
			word = readline.chomp
			generate_forever_interactive(spell) if word == 'crank'
			found = spell.check(word)
			puts found
		end
	rescue
		# shhhh, ended due to EOF or ctrl-c typically
	end
end

# main program entry point
def main
	consume = ARGV[0] == '-c'
	generate = ARGV[0] == '-g'
	ARGV.shift
	ARGV.shift
	interactive = ! (consume or generate)
	if generate
		generate_forever
	elsif consume
		check_forever
	else
		# interactive mode
		interactive_loop
	end
end

main
