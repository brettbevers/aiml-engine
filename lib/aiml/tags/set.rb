module AIML
  module Tags
    class Set < Base

      def self.tag_names
        [/^set_*/, 'set']
      end

      attr_reader :local_name, :body
      alias_method :value, :body

      def initialize(local_name, attributes)
        @local_name = attributes['name'] || local_name.sub(/^set_/, '')
        @body = []
      end

      def add(object)
        body.push(object)
      end

      def to_s(context)
        result = body.map { |token|
          token.to_s(context)
        }.join.strip
        context.set(local_name, result)
        return result
      end

      def inspect
        "set tag #{local_name} -> #{body.map(&:inspect).join(' ')}"
      end

    end
  end
end
