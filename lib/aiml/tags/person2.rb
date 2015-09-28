module AIML
  module Tags
    class Person2 < Base

      def self.tag_names
        %w{ person person2 }
      end

      PLACE_HOLDER = 'y-o-u'
      SWAP = {'yourself' => 'myself', 'myself' => 'yourself',
              'your' => 'my', 'yours' => 'mine', 'mine' => 'yours',
              'my' => 'your', 'me' => PLACE_HOLDER, 'i' => PLACE_HOLDER}
      SWAP_PARSER = /\b(#{SWAP.keys.join('|')})(\b|[^\w])/i

      YOU_PARSER = /\byou\b(\s*)(\b\w+\b)?/i

      alias_method :sentence, :body

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
        result
      end

    end
  end
end
