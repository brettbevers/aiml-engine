module AIML
  module Tags
    class MatchProperty < Base

      def self.tag_names
        [/^bot_\w+/, 'bot']
      end

      def name(context=nil)
        result = case local_name
                   when 'bot'
                     attributes["name"]
                   when /^bot_(\w+)/
                     $1
                 end
        context ? result.to_s(context) : result
      end

      def name?
        super || local_name =~ /^bot_(\w+)/
      end

      def ==(other)
        other.is_a?(AIML::Tags::MatchProperty) && self.body == other.body
      end
      alias_method :eql?, :==

      def hash
        body.hash
      end

      def match(pattern, graph, context)
        unless name?
          raise AIML::MissingAttribute, "'bot' tag must have 'name' attribute"
        end
        return unless pattern.key_matchable?
        value = context.get_property(name(context))
        path = AIML::Tags::Pattern.process(value)
        if path.zip(pattern.path).reduce(true) { |memo, pair| memo && pair[0] == pair[1] }
          graph.get_reaction(pattern.suffix(path.size))
        end
      end

      def inspect
        "match property #{name.inspect}"
      end

    end
  end
end
