module AIML
  module Tags
    class ReadProperty < Base

      def self.tag_names
        [/^bot_\w+/,'bot']
      end

      def name(context=nil)
        result = case local_name
                   when 'bot'
                     attributes["name"]
                   when /^bot_(\w+)/
                     $1
                 end
        context ? result.to_s(context) : result
      end

      def name?
        super || local_name =~ /^bot_(\w+)/
      end

      def to_s(context=nil)
        unless name?
          raise AIML::MissingAttribute, "'bot' tag must have 'name' attribute"
        end
        context.get_property(name(context))
      end

      def inspect
        "read property #{name.inspect}"
      end
    end
  end
end