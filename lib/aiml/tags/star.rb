module AIML
  module Tags
    class Star < Base

      def self.tag_names
        %w{ topicstar thatstar star }
      end

      alias_method :star, :local_name

      def to_s(context=nil)
        context.send(star, index)
      end

      def inspect
        "#{star} #{index}"
      end

      def index(context=nil)
        return 1 unless index?
        context ? attributes['index'].to_s(context).to_i : attributes['index'].to_i
      end

    end
  end
end
