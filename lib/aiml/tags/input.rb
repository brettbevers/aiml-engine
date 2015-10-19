module AIML
  module Tags
    class Input < Base

      INDEX_PARSER = /^(\d+),?(\d+|\*)?/

      def self.tag_names
        %w{ input request }
      end

      def first_index(context=nil)
        index = index(context) || ''
        INDEX_PARSER === index
        $1 || 1
      end

      def second_index(context=nil)
        index = index(context) || ''
        INDEX_PARSER === index
        $2 || '*'
      end

      def to_s(context=nil)
        input = context.get_stimulus(first_index(context).to_i)
        si = second_index(context)
        if si == '*'
          input.join('. ')
        else
          input[si.to_i-1]
        end
      end

      def inspect
        "input #{first_index.inspect},#{second_index.inspect} "
      end

    end
  end
end
