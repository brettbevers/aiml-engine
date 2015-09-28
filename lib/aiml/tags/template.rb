module AIML
  module Tags
    class Template < Base

      alias_method :value, :body

      def map(&block)
        body.map(&block)
      end

      def each(&block)
        body.each(&block)
      end

    end
  end
end
