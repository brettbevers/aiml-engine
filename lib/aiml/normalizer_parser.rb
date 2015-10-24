require_relative 'substitution_element'
require 'json'

module AIML
  class NormalizerParser

    attr_reader :learner

    def initialize(learner)
      @learner = learner
    end

    def parse(io)
      normalize = JSON.load(io)
      normalize.each do |key, value|
        next if key.empty?
        if %w{* # $ _ ^}.include?(key)
          learner.char_aliases[key] = value
        else
          learner.learn_normalizer_element AIML::SubstitutionElement.new(key, value)
        end
      end
    end

  end
end
