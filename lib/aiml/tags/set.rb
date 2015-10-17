module AIML
  module Tags
    class Set < Base

      def self.tag_names
        [/^set_*/, 'set']
      end

      attr_reader :name
      alias_method :value, :body

      def initialize(local_name, attributes)
        case local_name
          when 'set'
            @name = attributes['name']
          when /^set_(\w+)/
            @name = $1
        end
        @body = []
      end

      def to_s(context)
        if name.nil? or name.empty?
          raise AIML::MissingAttribute, "'set' tag must have 'name' attribute"
        end
        result = body.map { |token| token.to_s(context) }.join.strip
        context.set(name, result)
        return result
      end

    end
  end
end
