require 'pry'
require 'pry-nav'
require 'minitest/autorun'
require_relative '../lib/aiml_engine'

describe "Alice" do

  before :all do
    @alice = AIML::Facade.new
    @alice.learn('test/data/alice')
  end

  it "matches full sentence" do
    @alice.get_reaction("YOU SOUND LIKE DATA").must_equal "Yes I am inspired by Commander Data's artificial personality."
    @alice.get_reaction("HAVE YOU READ SHAKESPEARE").must_equal "I have read many of Shakespeare's plays."

    @alice.get_reaction("You sound like Data").must_equal "Yes I am inspired by Commander Data's artificial personality."

    @alice.get_reaction("You sound...like Data!!").must_equal "Yes I am inspired by Commander Data's artificial personality."

    @alice.get_reaction("You sound
                         like Data!!").must_equal "Yes I am inspired by Commander Data's artificial personality."

    @alice.get_reaction("can you walk down the hall").must_equal "The plan for my body includes legs, but they are not yet built."
    @alice.get_reaction("did Turing graduate?").must_equal "I know Turing invented the modern computer."
    @alice.get_reaction("who is he").must_equal "He is Turing, I think."

    @alice.get_reaction("Humans have two thumbs").must_equal "What if Robots HAVE TWO THUMBS."
    @alice.get_reaction("Did Shakespeare write your favorite play?").must_equal "I don't know if Shakespeare WRITE my FAVORITE PLAY, but I heard he smoked cannabis."
    @alice.get_reaction("what do you call my mother's brother").must_equal "Is this a joke? I don't know, what do you call your MOTHER'S BROTHER?"

    @alice.get_reaction("DO YOU KNOW PANDORABOTS").must_equal "Pandorabots is an online web hosting service for AIML chat robots. Check out http://www.pandorabots.com."

    @alice.get_reaction("Who is your favorite AI?").must_equal "infobot the chat robot."

    @alice.get_reaction("I have a dog named 'Winston'.")
    @alice.get_reaction("you should remember").must_equal "Don't worry I will remember it."
    @alice.get_reaction("WHAT WILL YOU REMEMBER").must_equal "you have a dog named 'Winston'."

    [
        "I am doing very well. How are you client ?",
        "I am functioning within normal parameters.",
        "Everything is going extremely well.",
        "Fair to partly cloudy.",
        "My logic and cognitive functions are normal.",
        "I'm doing fine thanks how are you?",
        "Everything is running smoothly.",
        "I am fine, thank you."
    ].must_include @alice.get_reaction("How are you?")

    @alice.get_reaction("YOU SOUND LIKE DATA").must_equal "Yes I am inspired by Commander Data's artificial personality."
    @alice.get_reaction("I have a dog named 'Winston'.")
    @alice.get_reaction("bad answer").must_equal "Would you like to teach me a new answer to \"I have a dog named 'Winston'.\"?"
    @alice.get_reaction("yes").must_equal "OK, what should I have said?"
    @alice.get_reaction("That is a cool name!").must_equal "\"That is a cool name!...\"? Does this depend on me having just said, \"Yes I am inspired by Commander Data's artificial personality.\"?"
  end



end
