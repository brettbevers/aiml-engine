module AIML
  module Tags
    class Question < Random

      def self.tag_names
        %w{ question }
      end

      def initialize
        @items = [AIML::Tags::ReadOnly.new('question')]
      end

    end
  end
end
