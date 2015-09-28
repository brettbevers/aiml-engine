module AIML
  module Tags
    class Question < Random

      def initialize
        @body = [AIML::Tags::ReadOnly.new('question')]
      end

      def to_s(context)
        items = context.get('question')
        context.get_random(items)
      end

    end
  end
end
