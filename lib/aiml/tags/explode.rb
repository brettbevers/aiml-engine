module AIML
  module Tags
    class Explode < Base

      def self.tag_names
        %w{ explode }
      end

      def initialize(text=nil)
        @body = [text].compact
      end

      def to_s(context)
        body.map{|item| item.to_s(context).gsub(/(\w)/,"\\1 ").gsub(/\s+/,' ') }.join
      end

    end
  end
end
