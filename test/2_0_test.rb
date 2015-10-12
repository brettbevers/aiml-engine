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
    @robot.get_reaction("My favorite color is Paris in the spring").must_equal "I didn't recognize PARIS IN THE SPRING as a color."
    @robot.get_reaction("my favorite color is green").must_equal "Green is my favorite color too!"
    @robot.get_reaction("I like green").must_equal "Green is my favorite color too!"
    @robot.get_reaction("I like violet blue").must_equal "VIOLET BLUE is a nice color."
    @robot.get_reaction("I like violet blue").must_equal "Repeated"
    @robot.get_reaction("My favorite color is red, Alice.").must_equal "RED is a nice color."
    @robot.get_reaction("My favorite color is red").must_equal "Topic alice. RED is a nice color."
    @robot.get_reaction("My favorite color is Air Force blue").must_equal "Topic alice. AIR FORCE BLUE is a nice color."
    @robot.get_reaction("My favorite color is Paris in the spring").must_equal "Topic alice. I didn't recognize PARIS IN THE SPRING as a color."
    @robot.get_reaction("my favorite color is green").must_equal "Topic alice. Green is my favorite color too!"
    @robot.get_reaction("I like green").must_equal "Topic alice. Topic alice. Green is my favorite color too!"
    @robot.get_reaction("I like violet blue").must_equal "Topic alice. Topic alice. VIOLET BLUE is a nice color."
    @robot.get_reaction("I like air force blue").must_equal "Topic alice. Repeated Repeated"
    @robot.get_reaction("My favorite color is red, Alice.").must_equal "Topic alice. Topic alice. RED is a nice color."

    @robot.get_reaction("My favorite color is red").must_equal "RED is a nice color."
  end

  it "matches #, ^ and $" do
    @robot.get_reaction("keyword").must_equal "Found KEYWORD"
    @robot.get_reaction("sharptest foo").must_equal "#star = FOO"
    @robot.get_reaction("sharptest foo bar test").must_equal "#star = FOO BAR"
    @robot.get_reaction("xyz abc carettest").must_equal "^star = XYZ ABC"
    @robot.get_reaction("carettest").must_equal "^star = UNDEF"
    @robot.get_reaction("carettest").must_equal "repeat"
    @robot.get_reaction("keyword").must_equal "Found KEYWORD"
    @robot.get_reaction("abc def keyword ghi jkl").must_equal "Found KEYWORD"
    @robot.get_reaction("abc keyword").must_equal "Found KEYWORD"
    @robot.get_reaction("keyword def").must_equal "Found KEYWORD"
    @robot.get_reaction("Who is Alice?").must_equal "I am Alice."
    @robot.get_reaction("My favorite color is red, Alice.").must_equal "RED is a nice color."

    @robot.get_reaction("keyword").must_equal "Topic alice. Found KEYWORD"
    @robot.get_reaction("sharptest foo").must_equal "Topic alice. #star = FOO"
    @robot.get_reaction("sharptest foo bar test").must_equal "Topic alice. #star = FOO BAR"
    @robot.get_reaction("xyz abc carettest").must_equal "Topic alice. ^star = XYZ ABC"
    @robot.get_reaction("carettest").must_equal "Topic alice. ^star = UNDEF"
    @robot.get_reaction("carettest").must_equal "repeat repeat"
    @robot.get_reaction("keyword").must_equal "Topic alice. Found KEYWORD"
    @robot.get_reaction("abc def keyword ghi jkl").must_equal "Topic alice. Found KEYWORD"
    @robot.get_reaction("abc keyword").must_equal "Topic alice. Found KEYWORD"
    @robot.get_reaction("keyword def").must_equal "Topic alice. Found KEYWORD"
    @robot.get_reaction("Who is Alice?").must_equal "Topic alice. I am Alice."
    @robot.get_reaction("My favorite color is red, Alice.").must_equal "Topic alice. Topic alice. RED is a nice color."

    @robot.get_reaction("keyword").must_equal "Found KEYWORD"
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
