spell
=====

quick and dirty spell checker challenge

simple spell checker library, as a small challenge

features:
  - if the word is in the dictionary, returns that one first
  - type the word crank to get it it start cranking words and checking them
    - it will generate 1000 words, check them, then print a dot
    - it will print a ! if it cannot march the generated word
  - start with ./spell.rb -g to generate words from the dictionary
  - start with ./spell.rb -c to consume lines with words from stdin and print the resulting match

this program entry point has three modes of operation:
  - generate words (with -g)
  - consume and check words from stdin (with -c)
  - interactive. type the word crank to start generating and checking forever

(C) 2012, Carlos Puchol <cpg at rocketmail dot com>

