module AIML
  module Tags
    class Think < Base

      alias_method :thoughts, :body

      def to_s(context)
        body.each do |thought|
          thought.to_s(context)
        end
        return ''
      end

    end
  end
end
