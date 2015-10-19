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

  it "parses sentences" do
    @robot.get_reaction("My favorite color is red.  My favorite color is Air Force blue.").
        must_equal "RED is a nice color.  AIR FORCE BLUE is a nice color."
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
    @robot.get_reaction("what is the capital of California?").must_equal "SACRAMENTO"
    @robot.get_reaction("what is the capital of the Moon?").must_equal "UNKNOWN"
    @robot.get_reaction("joe does work").must_equal "Now you can ask me: \"Who DOES WORK?\" and \"What does JOE DO?\""
    @robot.get_reaction("Who does work?").must_equal "JOE"
    @robot.get_reaction("What does joe do?").must_equal "WORK"
    @robot.get_reaction("Mercedes makes really expensive cars.").must_equal "Now you can ask me: \"What MAKES REALLY EXPENSIVE CARS?\" and \"What does MERCEDES MAKE?\""
    @robot.get_reaction("What makes really expensive cars?").must_equal "MERCEDES"
    @robot.get_reaction("What does MERCEDES make?").must_equal "REALLY EXPENSIVE CARS"
  end

  it "substitutes" do
    $stop = true
    @robot.get_reaction("normalize callmom-info@pandorabots.com").must_equal "callmom dash info at pandorabots dot com"
    @robot.get_reaction("denormalize that").must_equal "callmom-info@pandorabots.com"
    @robot.get_reaction("(212)-333-4444").must_equal "212 dash 333 dash 4444"
    @robot.get_reaction("denormalize that").must_equal "212-333-4444"
    @robot.get_reaction("I can not hear you").must_equal "I can not hear you"
    @robot.get_reaction("denormalize that").must_equal "I can't hear you"
  end

  it "explodes words" do
    @robot.get_reaction("Explode ABCDEF").must_equal "A B C D E F"
    @robot.get_reaction("Explode Dr. Alan Turing").must_equal "D R A L A N T U R I N G"
    @robot.get_reaction("Implode A B C D E F").must_equal "ABCDEF"
  end

  it "reads and matches properties" do
    @robot.get_reaction("Are you Hubert?").must_equal "Yes, I am."
    @robot.get_reaction("Who are you?").must_equal "I am Hubert."
    @robot.get_reaction("Are you Bob?").must_equal ""
  end

  it "gets and sets predicates" do
    @robot.get_reaction("My name is Bob").must_equal "OK, your name is BOB."
    @robot.get_reaction("Who are you?").must_equal "I am Hubert."
    @robot.get_reaction("Who am I?").must_equal "You are BOB."
  end

  it "gets and sets local variables" do
    @robot.get_reaction("TEST VAR").must_equal "TEST VAR:
unboundpredicate = UNKNOWN.
boundpredicate = some value.
unboundvar = UNKNOWN.
boundvar = something.
TEST VAR SRAI:
unboundpredicate = UNKNOWN.
boundpredicate = some value.
unboundvar = UNKNOWN.
boundvar = UNKNOWN."
  end

  it "evaluates conditionals" do
    @robot.get_reaction("He is going to Amsterdam").must_equal "Who is he?"
    @robot.get_reaction("He is the president").must_equal "OK, he is THE PRESIDENT."
    @robot.get_reaction("He is going to Amsterdam").must_equal "THE PRESIDENT is going to AMSTERDAM?"
    @robot.get_reaction("I am 12").must_equal "Your age is 12."
    @robot.get_reaction("I am Betty").must_equal "Your name is BETTY."
    @robot.get_reaction("I am wonderful").must_equal "Nope."
  end

  it "loops" do
    @robot.get_reaction("Count to 5").must_equal "1 2 3 4 5"
  end

end
