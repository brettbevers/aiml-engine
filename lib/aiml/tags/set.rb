module AIML
  module Tags
    class Set < Base

      def self.tag_names
        [/^set_*/, 'set']
      end

      alias_method :value, :body

      def initialize(local_name, attributes)
        @local_name = attributes['name'] || local_name.sub(/^set_/, '')
        @body = []
      end

      def to_s(context)
        result = body.map { |token|
          token.to_s(context)
        }.join.strip
        context.set(local_name, result)
        return result
      end

    end
  end
end
