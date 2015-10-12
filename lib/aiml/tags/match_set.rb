module AIML
  module Tags
    class MatchSet < Base

      attr_reader :graph_master

      def initialize(graph_master)
        @graph_master = graph_master
        @body = []
      end

      def ==(other)
        other.is_a?(AIML::Tags::MatchSet) && self.body == other.body
      end
      alias_method :eql?, :==

      def hash
        body.hash
      end

      def self.tag_names
        %w{ set }
      end

      def match(pattern)
        return unless pattern.key_matchable?
        path = prefix + pattern.path
        that = pattern.that
        topic = pattern.topic
        current_segment_type = pattern.current_segment_type
        prefixed_pattern = AIML::Tags::Pattern.new(path: path, that: that, topic: topic, current_segment_type: current_segment_type)
        response = graph_master.match_set(prefixed_pattern)
        response.decrement(prefix.size) if response
        response
      end

      def prefix
        @prefix ||= body.map { |token|
          case token
            when String
              AIML::Tags::Pattern.process_string(token)
          end
        }.flatten.compact
      end

    end
  end
end
