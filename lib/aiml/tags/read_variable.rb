module AIML
  module Tags
    class ReadVariable < Base

      def self.tag_names
        [/^get_\w+/,'get']
      end

      attr_reader :name

      def initialize(local_name, attributes={})
        case local_name
          when 'get'
            @name = attributes['name']
          when /^get_(.+)/
            @name = $1
        end
      end

      def to_s(context=nil)
        if name.nil? or name.empty?
          raise AIML::MissingAttribute, "'get' tag must have 'name' attribute"
        end
        context.get_variable(name)
      end

      def inspect
        "read variable #{name}"
      end
    end
  end
end
