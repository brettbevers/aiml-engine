module AIML
  module Tags
    class Loop < Base

      def self.tag_names
        ['loop']
      end

      attr_reader :condition

      def initialize(condition)
        @condition = condition
      end

      def to_s(context)
        condition.to_s(context).strip
      end

      def inspect
        "loop"
      end

    end
  end
end
