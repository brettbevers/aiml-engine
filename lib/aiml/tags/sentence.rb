module AIML
  module Tags
    class Sentence < Base

      def initialize(text=nil)
        @body = [text].compact
      end

      def to_s(context)
        body.map{|item| transform item.to_s(context) }.join
      end

      private

      def transform(str)
        self.class.transform(str)
      end

      def self.transform(str)
        str.capitalize.gsub(/\s+/,' ')
      end
    end
  end
end