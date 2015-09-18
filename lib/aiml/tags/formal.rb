module AIML
  module Tags
    class Formal < Base

      def self.tag_names
        %w{ formal }
      end

      attr_reader :body

      def initialize(text=nil)
        @body = [text].compact
      end

      def to_s(context)
        body.map{|item| item.to_s(context).gsub(/(\w+)/){ $1.capitalize }.gsub(/\s+/,' ') }.join
      end
    end
  end
end