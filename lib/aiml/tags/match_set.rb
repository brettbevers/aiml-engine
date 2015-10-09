module AIML
  module Tags
    class MatchSet < Base

      attr_reader :graph_master

      def initialize(graph_master)
        @graph_master = graph_master
        @body = []
      end

      def self.tag_names
        %w{ set }
      end

      def match(pattern)
        return unless pattern.path && pattern.stimulus
        path = prefix + pattern.path
        stimulus = prefix + pattern.stimulus
        that = pattern.that
        topic = pattern.topic
        current_segment = pattern.current_segment
        prefixed = AIML::Tags::Pattern.new(path: path, stimulus: stimulus, that: that, topic: topic, current_segment: current_segment)
        Search.new(prefixed, graph_master)
      end

      def prefix
        @prefix ||= body.map { |token|
          case token
            when String
              AIML::Tags::Pattern.process_string(token)
          end
        }.flatten.compact
      end

      class Search

        attr_reader :pattern, :graph_master

        def initialize(pattern, graph_master)
          @pattern = pattern
          @graph_master = graph_master
        end

        def each(&block)

        end

      end

    end
  end
end
