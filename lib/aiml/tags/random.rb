module AIML
  module Tags
    class Random < Base

      alias_method :items, :body

      def to_s(context)
        body.select { |token| token.is_a? AIML::Tags::ListItem }.sample.to_s(context)
      end

      def inspect
        "random -> #{body.map(&:inspect).join(' ')}"
      end

    end
  end
end
