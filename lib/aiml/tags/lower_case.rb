module AIML
  module Tags
    class LowerCase < Base

      def self.tag_names
        %w{ lowercase }
      end

      def initialize(text=nil)
        @body = [text].compact
      end

      def to_s(context)
        body.map{|item| item.to_s(context).downcase.gsub(/\s+/,' ') }.join
      end

    end
  end
end
