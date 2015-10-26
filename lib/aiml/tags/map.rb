module AIML
  module Tags
    class Map < Base

      def initialize(graph_master=nil, attributes={})
        @attributes   = attributes
        @graph_master = graph_master
        @body         = []
      end

      def to_s(context)
        processed_body = AIML::Tags::Pattern.process(body.map{ |token| token.to_s(context) })
        prefix = AIML::Tags::Pattern.process( name(context) )
        path = prefix + processed_body
        prefixed_pattern = AIML::Tags::Pattern.new(path: path)
        graph_master.map(prefixed_pattern, context)
      end

      def inspect
        "map -> #{name.inspect}"
      end

    end
  end
end