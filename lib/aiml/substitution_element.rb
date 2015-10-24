module AIML

  class SubstitutionElement

    attr_reader :key, :value, :path

    def initialize(key, value)
      @key      = key
      @value    = value.upcase
      @path     = process(key) + [AIML::RETURN]
    end

    def template
      AIML::Tags::Template.new.tap do |template|
        template.add(value)
      end
    end

    def self.process(str)
      str.upcase.each_char.to_a
    end

    def process(str)
      self.class.process(str)
    end

  end

end