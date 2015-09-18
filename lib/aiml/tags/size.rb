module AIML
  module Tags
    class Size < Base
      def to_s(context=nil)
        AIML::Tags::Category.cardinality.to_s
      end

      def inspect
        "size -> #{AIML::Tags::Category.cardinality.to_s}"
      end
    end
  end
end
