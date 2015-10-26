module AIML::Tags
  class Category

    def self.tag_names
      %w{ category }
    end

    attr_accessor :template, :that, :topic, :pattern

    @@cardinality = 0

    def initialize(topic=[])
      @@cardinality += 1
      @topic = topic
    end

    def self.cardinality
      @@cardinality
    end

    def path
      result = pattern.stimulus
      result += [AIML::THAT, that.path] if that && that.path.any?
      result += [AIML::TOPIC, topic] if topic && topic.any?
      result.flatten
    end

    def copy
      AIML::Tags::Category.new.tap do |result|
        result.template = template.copy
        result.that = that.copy if that
        result.topic = topic.dup if topic
        result.pattern = pattern.copy
      end
    end

  end
end
