require_relative 'substitution_element'
require 'json'

module AIML
  class DenormalizerParser

    attr_reader :learner

    def initialize(learner)
      @learner = learner
    end

    def parse(io)
      denormalize = JSON.load(io)
      denormalize.each do |key, value|
        next if key.empty?
        learner.learn_denormalizer_element AIML::SubstitutionElement.new(key, value)
      end
    end

  end
end
