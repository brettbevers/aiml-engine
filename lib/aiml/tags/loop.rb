module AIML
  module Tags
    class Loop < Base

      attr_reader :condition

      def initialize(condition=nil)
        @condition = condition
      end

      def to_s(context)
        condition.to_s(context)
      end

      def inspect
        "loop"
      end

    end
  end
end
