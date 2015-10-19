module AIML
  module Tags
    class Template < Base

      alias_method :value, :body

      def to_s(context)
        context.scoped do
         body.map{ |token| token.to_s(context) }.join.strip
        end
      end

      def map(&block)
        body.map(&block)
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
