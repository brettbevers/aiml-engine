module AIML
  module Tags
    class MatchPredicate < Base

      def self.tag_names
        [/^get_\w+/, 'get']
      end

      def name(context=nil)
        result = case local_name
                   when 'get'
                     attributes["name"]
                   when /^get_(\w+)/
                     $1
                 end
        context ? result.to_s(context) : result
      end

      def name?
        super || local_name =~ /^get_(\w+)/
      end

      def ==(other)
        other.is_a?(AIML::Tags::MatchPredicate) && self.body == other.body
      end
      alias_method :eql?, :==

      def hash
        body.hash
      end

      def match(pattern, graph, context)
        unless name?
          raise AIML::MissingAttribute, "'get' tag must have 'name' attribute"
        end
        return unless pattern.key_matchable?
        value = context.get_predicate(name(context))
        path = AIML::Tags::Pattern.process(value)
        if path.zip(pattern.path).reduce(true) { |memo, pair| memo && pair[0] == pair[1] }
          graph.get_reaction(pattern.suffix(path.size))
        end
      end

      def inspect
        "match variable #{name.inspect}"
      end

    end
  end
end
