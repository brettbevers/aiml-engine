module AIML
  module Tags
    class Condition < Base

      alias_method :items, :body
      alias_method :property, :name

      def to_s(context)
        validate_attributes!
        if value?
          return body.map{ |token| token.to_s(context) }.join if compare_values(context)
        else
          body.each do |item|
            return item.to_s(context) unless item.value?
            return item.to_s(context) if compare_values(context, item)
          end
        end
        String.new
      end

      def inspect
        k = if name?
              name.inspect
            elsif var?
              var.inspect
            end
        "condition #{k} = #{value.inspect} -> #{body.map(&:inspect).join(' ')}"
      end

      def compare_values(context, source=self)
        v = source.value(context) || ''
        v.gsub!('*', '.*?')
        get_value(context, source) =~ /^#{v}$/i
      end

      def get_value(context, source=self)
        if source.name?
          context.get_predicate(source.name(context))
        elsif source.var?
          context.get_variable(source.var(context))
        end
      end

      def validate_attributes!
        if name? && var?
          raise AIML::InvalidAttributes, "'condition' tag cannot have both 'name' and 'var' attributes"
        elsif value? && !(name? || var?)
          raise AIML::MissingAttribute, "'condition' tag must have either 'name' or 'var' attributes"
        end
      end

    end
  end
end
