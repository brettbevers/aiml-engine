module AIML
  module Tags
    class UpperCase < Base

      def initialize(text=nil)
        @body = [text].compact
      end

      def to_s(context)
        body.map{|item| item.to_s(context).upcase.gsub(/\s+/,' ') }.join
      end

    end
  end
end