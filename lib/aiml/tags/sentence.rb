module AIML
  module Tags
    class Sentence < Base

      def self.tag_names
        %w{ sentence }
      end

      attr_reader :body

      def initialize(text=nil)
        @body = [text].compact
      end

      def to_s(context)
        body.map{|item| item.to_s(context).capitalize.gsub(/\s+/,' ') }.join
      end
    end
  end
end