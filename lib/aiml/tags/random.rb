module AIML
  module Tags
    class Random < Base

      def self.tag_names
        %w{ random }
      end

      attr_reader :body
      alias_method :items, :body

      def initialize(attributes)
        @body = []
        name = attributes['name']
        if name && name != 'random'
          body.push AIML::Tags::ReadOnly.new(name)
        end
      end

      def add(object)
        body.push object
      end

      def get_item(context=nil)
        context.get_random(body)
      end

      def inspect
        "random -> #{body.map(&:inspect).join(' ')}"
      end

    end
  end
end
