module AIML
  module Tags
    class Get < Base

      def self.tag_names
        [/^get_\w+/, 'get']
      end

      def name(context=nil)
        n = case local_name
              when 'get'
                attributes['name']
              when /^get_(\w+)/
                $1
            end
        context ? n.to_s(context) : n
      end

      def name?
        super || local_name =~ /^get_(\w+)/
      end

      def to_s(context)
        validate_attributes!
        if name?
          context.get_predicate(name(context))
        elsif var?
          context.get_variable(var(context))
        end
      end

      def inspect
        if name?
          "read predicate #{name.inspect}"
        elsif var?
          "read variable #{var.inspect}"
        end
      end

      def validate_attributes!
        if !(name? || var?)
          raise AIML::MissingAttribute, "'get' tag must have either 'name' or 'var' attribute"
        elsif name? && var?
          raise AIML::InvalidAttributes, "'get' tag cannot have both 'name' and 'var' attributes"
        end
      end

    end
  end
end
