module AIML
  module Tags
    class MatchVariable < Base

      def self.tag_names
        [/^get_\w+/, 'get']
      end

      attr_reader :name

      def initialize(local_name=nil, attributes={})
        @body = []
        case local_name
          when 'get'
            @name = attributes["name"]
          when /^get_(\w+)/
            @name = $1
        end
      end

      def ==(other)
        other.is_a?(AIML::Tags::MatchVariable) && self.body == other.body
      end
      alias_method :eql?, :==

      def hash
        body.hash
      end

      def match(pattern, graph, context)
        if name.nil? or name.empty?
          raise AIML::MissingAttribute, "'get' tag must have 'name' attribute"
        end
        return unless pattern.key_matchable?
        value = context.get_variable(name)
        path = AIML::Tags::Pattern.process(value)
        if path.zip(pattern.path).reduce(true) { |memo, pair| memo && pair[0] == pair[1] }
          graph.get_reaction(pattern.suffix(path.size))
        end
      end

      def inspect
        "match variable #{name}"
      end

    end
  end
end
