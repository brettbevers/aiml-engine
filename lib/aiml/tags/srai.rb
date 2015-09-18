module AIML
  module Tags
    class Srai < Base

      def self.tag_names
        %w{ srai  sr }
      end

      attr_reader :body
      alias_method :pattern, :body

      def initialize(object=nil)
        @body = [object].compact
      end

      def add(object)
        body.push(object)
      end

      def to_path(context)
        body.map do |token|
          token.to_s(context).upcase.strip.split(/\s+/)
        end
      end

      def inspect
        "srai -> #{body.map(&:inspect).join(' ')}"
      end

    end
  end
end
