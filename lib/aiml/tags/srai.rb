module AIML
  module Tags
    class Srai < Base

      def self.tag_names
        %w{ srai  sr }
      end

      attr_reader :body

      def initialize(object=nil)
        @body = [object].compact
      end

      def add(object)
        body.push(object)
      end

      def to_path(context)
        body.map do |token|
          token.to_s(context).upcase.strip.split(/\s+/)
        end
      end

      def to_pattern(context)
        stimulus = to_path(context)
        path = [stimulus, THAT, process_string(context.that), TOPIC, process_string(context.topic)].flatten
        AIML::Tags::Pattern.new(path: path, stimulus: stimulus, that: context.that, topic: context.topic)
      end

      def to_s(context)
        graph_master = context.graph_masters[-1]
        pattern = self.to_pattern(context)
        graph_master.render_reaction(pattern, context)
      end

      def inspect
        "srai -> #{body.map(&:inspect).join(' ')}"
      end

      private

      def process_string(str)
        AIML::Tags::Pattern.process_string(str)
      end

    end
  end
end
