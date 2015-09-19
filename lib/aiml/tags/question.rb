module AIML
  module Tags
    class Question < Random

      def self.tag_names
        %w{ question }
      end

      def initialize
        @body = [AIML::Tags::ReadOnly.new('question')]
      end

    end
  end
end
