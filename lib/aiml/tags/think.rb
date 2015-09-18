module AIML
  module Tags
    class Think < Base

      def self.tag_names
        %w{ think }
      end

      attr_reader :body
      alias_method :thoughts, :body

      def initialize
        @body = []
      end

      def add(object)
        body.push object
      end

      def to_s(context=nil)
        body.each do |thought|
          thought.to_s(context)
        end
        return ''
      end

      def inspect
        "think -> #{body.map(&:inspect).join(' ')}"
      end
    end
  end
end
