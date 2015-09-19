module AIML
  module Tags
    class Condition < Base

      def self.tag_names
        %w{ condition }
      end

      attr_reader :property, :value, :body
      alias_method :items, :body

      def initialize(attributes)
        @body = []
        @property = attributes['name']
        @value = attributes['value']
      end

      def add(item)
        body.push item
      end

      def to_s(context=nil)
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
