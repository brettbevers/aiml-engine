module AIML
  module Tags
    class ReadProperty < Base

      def self.tag_names
        [/^bot_\w+/,'bot']
      end

      attr_reader :name

      def initialize(local_name, attributes={})
        case local_name
          when 'bot'
            @name = attributes['name']
          when /^bot_(.+)/
            @name = $1
        end
      end

      def to_s(context=nil)
        if name.nil? or name.empty?
          raise AIML::MissingAttribute, "'bot' tag must have 'name' attribute"
        end
        context.get_property(name)
      end

      def inspect
        "read property #{name}"
      end
    end
  end
end