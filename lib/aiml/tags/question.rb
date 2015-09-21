module AIML
  module Tags
    class Question < Random

      def self.tag_names
        %w{ question }
      end

      def initialize
        @body = [AIML::Tags::ReadOnly.new('question')]
      end

      def get_item(context)
        items = context.get('question')
        context.get_random(items)
      end

    end
  end
end
