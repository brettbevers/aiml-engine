module AIML::Tags

    class That < Base

      INDEX_PARSER = /^(\d+),?(\d+|\*)?/

      alias_method :path, :body

      def self.tag_names
        %w{ that response }
      end

      def first_index(context=nil)
        index = index(context) || ''
        $1 if INDEX_PARSER === index
      end

      def second_index(context=nil)
        index = index(context) || ''
        $2 if INDEX_PARSER === index
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
        context.that(first_index(context), second_index(context))
      end

      def inspect
        "that #{first_index.inspect},#{second_index.inspect} "
      end

    end

end
