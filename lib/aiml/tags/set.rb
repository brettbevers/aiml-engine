module AIML
  module Tags
    class Set < Base

      def self.tag_names
        [/^set_*/, 'set']
      end

      def name(context=nil)
        n = case local_name
              when 'set'
                attributes['name']
              when /^set_(\w+)/
                $1
            end
        context ? n.to_s(context) : n
      end

      def name?
        super || local_name =~ /^set_(\w+)/
      end

      def to_s(context)
        validate_attributes!
        result = body.map { |token| token.to_s(context) }.join.strip
        if name?
          context.set_predicate(name(context), result)
        elsif var?
          context.set_variable(var(context), result)
        end
        return result
      end

      def inspect
        if name?
          "set predicate #{name.inspect}"
        elsif var?
          "set variable #{var.inspect}"
        end
      end

      def validate_attributes!
        if !(name? || var?)
          raise AIML::MissingAttribute, "'set' tag must have either 'name' or 'var' attribute"
        elsif name? && var?
          raise AIML::InvalidAttributes, "'set' tag cannot have both 'name' and 'var' attributes"
        end
      end

    end
  end
end
