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
  end

  it "normalizes case" do
    @alice.get_reaction("You sound like Data").must_equal "Yes I am inspired by Commander Data's artificial personality."
  end

  it "normalizes punctuation" do
    @alice.get_reaction("You sound...like Data!!").must_equal "Yes I am inspired by Commander Data's artificial personality."
  end

  it "normalizes white space" do
    @alice.get_reaction("You sound
                         like Data!!").must_equal "Yes I am inspired by Commander Data's artificial personality."
  end

  it "matches star as wildcard" do
    @alice.get_reaction("can you walk down the hall").must_equal "The plan for my body includes legs, but they are not yet built."
  end

  it "implements <person/>" do
    @alice.get_reaction("Humans have two thumbs").must_equal "What if Robots HAVE TWO THUMBS."
  end

  it "implements recursive pattern matching" do
    @alice.get_reaction("DO YOU KNOW PANDORABOTS").must_equal "Pandorabots is an online web hosting service for AIML chat robots. Check out http://www.pandorabots.com."
  end

  it "implements read-only tags" do
    @alice.get_reaction("Who is your favorite AI?").must_equal "infobot the chat robot."
  end

  it "implements set and get tags" do
    @alice.get_reaction("I have a dog named 'Winston'.")
    @alice.get_reaction("you should remember").must_equal "Don't worry I will remember it."
    @alice.get_reaction("WHAT WILL YOU REMEMBER").must_equal "you have a dog named 'Winston'."
  end

  it "implements random reaction" do
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
  end




end
