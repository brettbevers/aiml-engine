module AIML
  module Tags
    class ListItem < Base

      def self.tag_names
        %w{ li }
      end

      attr_reader :attributes, :body
      alias_method :template, :body

      def initialize(attributes={})
        @attributes = attributes
        @body = []
      end

      def add(object)
        body.push object
      end

      def to_s(context)
        body.map{|token| token.to_s(context) }.join
      end

      def inspect
        "list item #{attributes} -> #{body.map(&:inspect).join(' ')}"
      end

    end
  end
end