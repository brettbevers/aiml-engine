module AIML
  module Tags

    class That < Base

      INDEX_PARSER = /^(\d+),?(\d+|\*)?/

      def self.tag_names
        %w{ that }
      end

      attr_reader :body, :first_index, :second_index
      alias_method :path, :body

      def initialize(attributes={})
        @body = []
        index = attributes['index'] || ''
        INDEX_PARSER === index
        @first_index  = $1 || 1
        @second_index = $2 || 1
      end

      def add(object)
        case object
          when String
            @body = @body + AIML::Tags::Pattern.process_string(object)
          else
            body.push(object)
        end
      end

      def to_s(context=nil)
        input = context.that(first_index.to_i)
        if second_index == '*'
          return input
        else
          return input.split(/(\.\?!\n)\s*/)[second_index.to_i-1]
        end
      end

      def inspect
        "that #{first_index},#{second_index}"
      end

    end

  end
end