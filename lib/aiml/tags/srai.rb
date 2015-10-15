module AIML
  module Tags
    class Srai < Base

      def self.tag_names
        %w{ srai  sr }
      end

      def initialize(object=nil)
        @body = [object].compact
      end

      def to_path(context)
        body.map { |token|
          process(token.to_s(context))
        }.flatten
      end

      def to_pattern(context)
        stimulus = to_path(context)
        that = process_that(context.that)
        topic = process_topic(context.topic)
        path = [stimulus, THAT, that, TOPIC, topic].flatten
        AIML::Tags::Pattern.new(path: path, stimulus: stimulus, that: that, topic: topic)
      end

      def to_s(context)
        graph_master = context.graph_masters[-1]
        pattern = self.to_pattern(context)
        graph_master.render_reaction(pattern, context)
      end

      private

      def process(obj)
        AIML::Tags::Pattern.process(obj)
      end

      def process_that(that)
        result = process(that)
        result.empty? ? [UNDEF] : result
      end

      def process_topic(topic)
        result = process(topic)
        result.empty? ? [DEFAULT] : result
      end

    end
  end
end
