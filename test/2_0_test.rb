require 'pry'
require 'pry-nav'
require 'minitest/autorun'
require 'date'
require_relative '../lib/aiml_engine'

describe "AIML 2.0" do

  before do
    @robot = AIML::Facade.new
    @robot.learn('test/data/2_0_test')
  end

  it "matches sets" do
    @robot.get_reaction("My favorite color is red").must_equal "RED is a nice color."

    @robot.get_reaction("My favorite color is Air Force blue").must_equal "AIR FORCE BLUE is a nice color."

    @robot.get_reaction("My favorite color is Paris in the spring").must_equal " didn't recognize PARIS IN THE SPRING as a color."

    @robot.get_reaction("I like violet blue").must_equal "VIOLET BLUE is a nice color."
  end

  it "matches #, ^ and $" do
    @robot.get_reaction("keyword").must_equal "Found KEYWORD"
    @robot.get_reaction("sharptest foo").must_equal "#star = foo"
    @robot.get_reaction("sharptest foo bar test").must_equal "#star = foo bar"
    @robot.get_reaction("xyz abc carettest").must_equal "^star = xyz abc"
    @robot.get_reaction("carettest").must_equal "^star = unknown"
    @robot.get_reaction("keyword").must_equal "Found KEYWORD"
    @robot.get_reaction("abc def keyword ghi jkl").must_equal "Found KEYWORD"
    @robot.get_reaction("abc keyword").must_equal "Found KEYWORD"
    @robot.get_reaction("keyword def").must_equal "Found KEYWORD"
    @robot.get_reaction("Who is Alice?").must_equal "I am Alice."
    @robot.get_reaction("My favorite color is red, Alice.").must_equal "Red is a nice color."

  end

  it "maps" do

  end

  it "substitutes" do

  end

  it "loads default predicates" do

  end

  it "loads default properties" do

  end

  it "reacts" do

  end

end
