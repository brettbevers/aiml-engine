module AIML
  module Tags
    class ListItem < Base

      def self.tag_names
        %w{ li }
      end

      alias_method :template, :body

      def inspect
        "list item #{attributes} -> #{body.map(&:inspect).join(' ')}"
      end

      def name
        attributes['name']
      end
      alias_method :property, :name

      def value
        attributes['value']
      end

      def value?
        attributes.key?('value')
      end

    end
  end
end
