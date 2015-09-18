module AIML
  module Tags
    class Person < Base

      def self.tag_names
        %w{ person }
      end

      SWAP = {'male' => {'me' => 'him',
                         'my' => 'his',
                         'myself' => 'himself',
                         'mine' => 'his',
                         'i' => 'he',
                         'he' => 'i',
                         'she' => 'i'},
              'female' => {'me' => 'her',
                           'my' => 'her',
                           'myself' => 'herself',
                           'mine' => 'hers',
                           'i' => 'she',
                           'he' => 'i',
                           'she' => 'i'}}

      attr_reader :body
      alias_method :sentence, :body

      def initialize
        @body = []
      end

      def add(object)
        body.push(object)
      end

      def to_s(context=nil)
        result = ''
        body.each { |token|
          result += token.to_s(context)
        }
        gender = context.get('gender')
        result.gsub!(/\b(she|he|i|me|my|myself|mine)\b/i) {
          SWAP[gender][$1.downcase]
        }
        result
      end

      def inspect
        "person-> #{body.map(&:inspect).join(' ')}"
      end
    end
  end
end
