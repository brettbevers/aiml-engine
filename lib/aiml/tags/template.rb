module AIML
  module Tags
    class Template < Base

      def self.tag_names
        %w{ template }
      end

      attr_reader :body
      alias_method :value, :body

      def initialize
        @body = []
      end

      def map(&block)
        value.map(&block)
      end

      def each(&block)
        value.each(&block)
      end

      def add(object)
        value.push object
      end

      def inspect
        value.map(&:inspect).join(' ')
      end
    end
  end
end
