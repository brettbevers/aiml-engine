module AIML
  module Tags
    class Formal < Base

      def initialize(text=nil)
        @body = [text].compact
      end

      def to_s(context)
        body.map{|item| item.to_s(context).gsub(/(\w+)/){ $1.capitalize }.gsub(/\s+/,' ') }.join
      end
    end
  end
end