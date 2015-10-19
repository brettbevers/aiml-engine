module AIML
  module Tags
    class ListItem < Base

      def self.tag_names
        %w{ li }
      end

      alias_method :template, :body
      alias_method :property, :name

      def inspect
        "list item #{attributes} -> #{body.map(&:inspect).join(' ')}"
      end

    end
  end
end
