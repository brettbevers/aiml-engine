module AIML
  module Tags
    class Random < Base

      alias_method :items, :body

      def to_s(context)
        body[rand(body.length)].to_s(context)
      end

      def inspect
        "random -> #{body.map(&:inspect).join(' ')}"
      end

    end
  end
end
