module AIML
  module Tags
    class Person < Base

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

      alias_method :sentence, :body

      def to_s(context=nil)
        result = ''
        body.each { |token|
          result += token.to_s(context)
        }
        gender = context.get_property('gender')
        result.gsub!(/\b(she|he|i|me|my|myself|mine)\b/i) {
          SWAP[gender][$1.downcase]
        }
        result
      end

    end
  end
end
