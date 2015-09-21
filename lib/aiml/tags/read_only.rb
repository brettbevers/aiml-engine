module AIML
  module Tags
    class ReadOnly < Base

      def self.tag_names
        [/^get.*/, /^bot_.*/, 'for_fun', 'bot', 'name']
      end

      attr_reader :name, :first_index, :second_index

      def initialize(local_name, attributes={})
        case local_name
          when 'get'
            @name = attributes['name']
          when 'bot'
            suffix = attributes["name"] || "name"
            @name = "bot_#{suffix}"
          else
            @name = local_name.sub(/^get_/, '')
        end
      end

      def to_s(context=nil)
        context.get(name)
      end

      def inspect
        "read only tag #{name}"
      end
    end
  end
end