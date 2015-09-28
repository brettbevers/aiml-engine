module AIML
  module Tags
    class Category

      def self.tag_names
        %w{ category }
      end

      attr_accessor :template, :that, :topic, :pattern

      @@cardinality = 0

      def initialize(topic=nil)
        @@cardinality += 1
        @topic = topic.strip.upcase.split(/\s+/) if topic
      end

      def self.cardinality
        @@cardinality
      end

      def path
        result = pattern.stimulus
        result += [AIML::THAT, that.path] if that
        result += [AIML::TOPIC, topic] if topic
        result.flatten
      end

    end
  end
end
