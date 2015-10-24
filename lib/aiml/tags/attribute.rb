module AIML
  module Tags
    class Attribute < Base

      def self.tag_names
        %w{ name var value index format style from to }
      end

      def inspect
        "attribute #{local_name} -> #{body.map(&:inspect).join(' ')}"
      end

    end
  end
end
