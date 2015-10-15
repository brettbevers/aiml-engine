module AIML
  module Tags
    class Input < Base

      INDEX_PARSER = /^(\d+),?(\d+|\*)?/

      attr_reader :first_index, :second_index

      def initialize(attributes)
        index = attributes['index'] || ''
        INDEX_PARSER === index
        @first_index  = $1 || 1
        @second_index = $2 || 1
      end

      def to_s(context=nil)
        input = context.get_stimulus(first_index.to_i)
        if second_index == '*'
          input.join('. ')
        else
          input[second_index.to_i-1]
        end
      end

      def inspect
        "input #{first_index},#{second_index} "
      end

    end
  end
end
