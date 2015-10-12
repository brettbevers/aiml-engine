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

      def size
        body.size
      end

      def join(*args)
        body.join(*args)
      end

      def empty?
        body.empty?
      end

    end
  end
end
