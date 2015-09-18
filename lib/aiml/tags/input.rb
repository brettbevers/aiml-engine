module AIML
  module Tags
    class Input < Base

      attr_reader :index

      def initialize(attributes)
        @index = (attributes['index'] || 1).to_i
      end

      def to_s(context=nil)
        context.get_stimulus(index)
      end

      def inspect
        "input #{index}"
      end

    end
  end
end
