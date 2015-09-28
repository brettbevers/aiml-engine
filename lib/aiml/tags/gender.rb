module AIML
  module Tags
    class Gender < Base

      PRONOUN_MAP = {
          'he' => 'she',
          'she' => 'he',
          'herself' => 'himself',
          'himself' => 'herself',
          'hisself' => 'herself',
          'hers' => 'his',
          'him' => 'her'
      }

      POSSESIVE_MAP = {
          'his' => 'her',
          'her' => 'his'
      }

      NOUN_MAP = {
          'his' => 'hers',
          'her' => 'him'
      }

      PRONOUN_PARSER = /\b(#{PRONOUN_MAP.keys.join('|')})\b/i
      HIS_HER_PARSER = /\b(his|her)\b(\s*)(\b\w*\b)?/i

      alias_method :sentence, :body

      def to_s(context=nil)
        result = ''
        body.each { |token|
          result += token.to_s(context)
        }
        result.gsub!(PRONOUN_PARSER) { PRONOUN_MAP[$1.downcase] }
        result.gsub!(HIS_HER_PARSER) {
          pronoun = $1.downcase
          space = $2
          next_word = $3
          if next_word && (AIML::TAGGER.add_tags(next_word) =~ /^<n\w+>#{next_word}/i)
            "#{POSSESIVE_MAP[pronoun]}#{space}#{next_word}"
          else
            "#{NOUN_MAP[pronoun]}#{space}#{next_word}"
          end
        }
        result
      end

      def inspect
        "gender -> #{body.map(&:inspect).join(' ')}"
      end
    end
  end
end
