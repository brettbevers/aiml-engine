module AIML
  module Tags
    class Command < Base

      def self.tag_names
        %w{ system }
      end

      attr_reader :body
      alias_method :command, :body

      def initialize(text=nil)
        @body = [text].compact
      end

      def add(object)
        body.push object
      end

      def to_s(context)
        cmd = body.map { |token| token.to_s(context) }.join
        `#{cmd}`.strip
      end

      def inspect
        "cmd -> #{body.map(&:inspect).join(' ')}"
      end
    end
  end
end
