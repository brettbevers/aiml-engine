module AIML
  module Tags
    class Normalize < Base

      def initialize(graph_master=nil, attributes={})
        @attributes   = attributes
        @graph_master = graph_master
        @body         = []
      end

      def to_s(context)
        processed_body = body.map{ |token| token.to_s(context) }.join
        graph_master.normalize(processed_body)
      end

      def inspect
        "normalize -> #{body.map(&:inspect).join(' ')}"
      end

    end
  end
end
