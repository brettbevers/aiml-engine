module AIML
  module Tags
    class Denormalize < Base

      def initialize(graph_master=nil, attributes={})
        @attributes   = attributes
        @graph_master = graph_master
        @body         = []
      end

      def to_s(context)
        processed_body = body.map{ |token| token.to_s(context) }.join
        graph_master.denormalize(processed_body)
      end

      def inspect
        "denormalize -> #{body.map(&:inspect).join(' ')}"
      end

    end
  end
end