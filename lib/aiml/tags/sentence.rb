module AIML
  module Tags
    class Sentence < Base

      def initialize(text=nil)
        @body = [text].compact
      end

    end
  end
end