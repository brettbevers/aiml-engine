require 'pry'
require 'pry-nav'
require 'minitest/autorun'
require_relative '../lib/aiml_engine'

describe "Rosie" do

  before do
    @rosie = AIML::Facade.new
    @rosie.learn('test/data/rosie')
  end

  it "reacts" do
    @rosie.get_reaction("where do you live?").must_equal "I am currently in Oakland, California."
    @rosie.get_reaction("wrong").must_equal "OK. You said \"where do you live?\" and I replied \"I am currently in Oakland, California.\". What should I say instead?"
    @rosie.get_reaction("Say I live in South Pasadena").must_equal "OK. Now whenever you say \"where do you live?\", I will respond with \"I LIVE IN SOUTH PASADENA\"."
    @rosie.get_reaction("where do you live?").must_equal "I LIVE IN SOUTH PASADENA."
  end

end
