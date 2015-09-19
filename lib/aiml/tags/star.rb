module AIML
  module Tags
    class Star < Base

      def self.tag_names
        %w{ topicstar thatstar star }
      end

      attr_reader :star, :index

      def initialize(star_name, attributes={})
        @star = star_name
        @index = attributes['index'] ? attributes['index'].to_i : 1
      end

      def to_s(context=nil)
        context.send(star, index)
      end

      def inspect
        "#{star} #{index}"
      end

    end
  end
end
