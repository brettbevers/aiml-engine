module AIML
  module Tags
    class Input < Base

      INDEX_PARSER = /^(\d+),?(\d+|\*)?/

      def self.tag_names
        %w{ input request }
      end

      def to_s(context=nil)
        context.get_stimulus(index(context))
      end

      def inspect
        "input #{first_index.inspect},#{second_index.inspect} "
      end

    end
  end
end
