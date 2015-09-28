module AIML
  module Tags
    class ListItem < Base

      def self.tag_names
        %w{ li }
      end

      attr_reader :attributes
      alias_method :template, :body

      def initialize(attributes={})
        @attributes = attributes
        @body = []
      end

      def inspect
        "list item #{attributes} -> #{body.map(&:inspect).join(' ')}"
      end

    end
  end
end
