module AIML
  module Tags

    class That < Base

      def self.tag_names
        %w{ that }
      end

      attr_reader :body
      alias_method :path, :body

      def initialize
        @body = []
      end

      def add(object)
        case object
          when String
            @body = @body + object.strip.upcase.split(/\s+/)
          else
            body.push(object)
        end
      end

    end

  end
end
