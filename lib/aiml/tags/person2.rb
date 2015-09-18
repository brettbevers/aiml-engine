module AIML
  module Tags
    class Person2 < Base

      def self.tag_names
        %w{ person2 }
      end

      PLACE_HOLDER = 'y-o-u'
      SWAP = {'my' => 'your', 'me' => PLACE_HOLDER, 'i' => PLACE_HOLDER}
      SWAP_PARSER = /\b(#{SWAP.keys.join('|')})(\b|[^\w])/i

      YOU_PARSER = /\byou\b(\s*)(\b\w+\b)?/i

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
        result.gsub!(SWAP_PARSER) {
          SWAP[$1.downcase]
        }

        result.gsub!(YOU_PARSER) {
          space = $1
          next_word = $2
          if next_word && (AIML::TAGGER.add_tags(next_word) =~ /^<(md|v\w*)>#{next_word}/i)
            "i#{space}#{next_word}"
          else
            "me#{space}#{next_word}"
          end
        }

        result.gsub!(/#{PLACE_HOLDER}/, 'you')
      end

      def inspect
        "person2 -> #{body.map(&:inspect).join(' ')}"
      end
    end
  end
end
