require_relative 'set_element'

module AIML
  class SetParser

    attr_reader :learner

    def initialize(learner)
      @learner = learner
    end

    def parse(io)
      set_name = File.basename(io.path, '.set')
      io.each_line do |line|
        next if line.empty?
        learner.learn_set_element AIML::SetElement.new(set_name, line)
      end
    end

  end
end