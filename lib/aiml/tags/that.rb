module AIML
  module Tags

    class That < Base

      INDEX_PARSER = /^(\d+),?(\d+|\*)?/

      alias_method :path, :body

      def self.tag_names
        %w{ that response }
      end

      def first_index(context=nil)
        index = index(context) || ''
        INDEX_PARSER === index
        $1 || 1
      end

      def second_index(context=nil)
        index = index(context) || ''
        INDEX_PARSER === index
        $2 || default_second_index
      end

      def default_second_index
        case local_name
          when 'response'
            '*'
          when 'that'
            1
        end
      end

      def add(object)
        case object
          when String, Array
            @body = @body + AIML::Tags::Pattern.process(object)
          else
            body.push(object)
        end
      end

      def to_s(context=nil)
        input = context.that(first_index(context).to_i)
        si = second_index(context)
        if si == '*'
          return input.join(' ')
        else
          return input[si.to_i-1]
        end
      end

      def inspect
        "that #{first_index.inspect},#{second_index.inspect} "
      end

    end

  end
end
