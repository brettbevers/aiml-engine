module AIML
  module Tags
    class Condition < Base

      alias_method :items, :body

      def to_s(context)
        body.each do |item|
          return item.to_s(context) unless item.value?
          p = item.name
          v = item.value || ''
          v.gsub!('*', '.*?')
          return item.to_s(context) if context.get_variable(p) =~ /^#{v}$/i
        end
        return ''
      end

      def inspect
        "condition #{property} = #{value} -> #{body.map(&:inspect).join(' ')}"
      end

      def name
        attributes['name']
      end
      alias_method :property, :name

      def value
        attributes['value']
      end

      def value?
        attributes.key?('value')
      end

      def name?
        attributes.key?('name')
      end

    end
  end
end
