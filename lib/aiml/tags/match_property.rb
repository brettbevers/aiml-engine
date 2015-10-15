module AIML
  module Tags
    class MatchProperty < Base

      def self.tag_names
        [/^bot_\w+/, 'bot']
      end

      attr_reader :name

      def initialize(local_name=nil, attributes={})
        @body = []
        case local_name
          when 'bot'
            @name = attributes["name"] || "name"
          when /^bot_(\w+)/
            @name = $1
        end
      end

      def ==(other)
        other.is_a?(AIML::Tags::MatchProperty) && self.body == other.body
      end
      alias_method :eql?, :==

      def hash
        body.hash
      end

      def match(pattern, graph, context)
        if name.nil? or name.empty?
          raise AIML::MissingAttribute, "'bot' tag must have 'name' attribute"
        end
        return unless pattern.key_matchable?
        value = context.get_property(name)
        path = AIML::Tags::Pattern.process(value)
        if path.zip(pattern.path).reduce(true) { |memo, pair| memo && pair[0] == pair[1] }
          graph.get_reaction(pattern.suffix(path.size))
        end
      end

      def inspect
        "match property #{name}"
      end

    end
  end
end
