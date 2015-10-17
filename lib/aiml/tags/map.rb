module AIML
  module Tags
    class Map < Base

      attr_reader :graph_master

      def initialize(graph_master, attributes)
        @attributes   = attributes
        @graph_master = graph_master
        @body         = []
      end

      def to_s(context)
        processed_body = AIML::Tags::Pattern.process(body.map{ |token| token.to_s(context) })
        path = prefix + processed_body
        prefixed_pattern = AIML::Tags::Pattern.new(path: path)
        graph_master.map(prefixed_pattern, context)
      end

      def inspect
        "map -> #{name}"
      end

      def name
        @name ||= attributes['name']
      end

      def prefix
        @prefix ||= AIML::Tags::Pattern.process(name)
      end

    end
  end
end
