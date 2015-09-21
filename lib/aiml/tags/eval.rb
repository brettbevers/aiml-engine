module AIML::Tags
  class Eval < Base

    def self.tag_names
      %w{ eval }
    end

    attr_reader :body

    def initialize
      @body = []
    end

    def add(object)
      body.push object
    end

    def to_s(context)
    end

  end
end