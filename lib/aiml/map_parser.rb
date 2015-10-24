require_relative 'map_element'
require 'json'

module AIML
  class MapParser

    attr_reader :learner

    def initialize(learner)
      @learner = learner
    end

    def parse(io)
      map_name = File.basename(io.path, '.map')
      map = JSON.load(io)
      map.each do |key, value|
        next if key.empty?
        learner.learn_map_element AIML::MapElement.new(map_name, key, value)
      end
    end

  end
end