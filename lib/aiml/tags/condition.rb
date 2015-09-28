module AIML
  module Tags
    class Condition < Base

      attr_reader :property, :value
      alias_method :items, :body

      def initialize(attributes)
        @body = []
        @property = attributes['name']
        @value = attributes['value']
      end

      def to_s(context)
        body.each do |item|
          p = item.attributes['name']
          v = (item.attributes['value'] || '').gsub('*', '.*?')
          return item.to_s(context) if context.get(p) =~ /^#{v}$/i
        end
        return ''
      end

      def inspect
        "condition #{property} = #{value} -> #{body.map(&:inspect).join(' ')}"
      end

    end
  end
end
