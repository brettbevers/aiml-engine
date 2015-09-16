require_relative 'tags/pattern'

module AIML::Tags

  class That

    TAG_NAMES = %w{ that }

    attr_accessor :path

    def initialize
      @path = []
    end

    def add(body)
      case body
        when String
          self.path += body.strip.upcase.split(/\s+/)
        else
          path.push(body)
      end
    end

  end

  class Category

    TAG_NAMES = %w{ category }

    attr_accessor :template, :that, :topic, :pattern

    @@cardinality = 0

    def initialize(topic=nil)
      @@cardinality += 1
      @topic = topic.strip.upcase.split(/\s+/) if topic
    end

    def self.cardinality
      @@cardinality
    end

    def path
      result = pattern.stimulus
      result += [AIML::THAT, that.path] if that
      result += [AIML::TOPIC, topic] if topic
      result.flatten
    end

  end

  class Template

    TAG_NAMES = %w{ template }

    attr_accessor :value

    def initialize
      @value = []
    end

    def map(&block)
      value.map(&block)
    end

    def each(&block)
      value.each(&block)
    end

    def add(object)
      value.push object
    end

    def inspect
      value.map(&:inspect).join(' ')
    end
  end

  class Random

    TAG_NAMES = %w{ random }

    attr_reader :items

    def initialize(attributes)
      @items = [nil, 'random'].include?(attributes['name']) ? [] : [AIML::Tags::ReadOnlyTag.new(name)]
    end

    def add(body)
      items.push body
    end

    def to_s(context=nil)
      choices = items.map { |item| item.to_s(context) }.flatten
      context.get_random(choices).strip
    end

    def inspect
      "random -> #{items.map(&:inspect).join(' ')}"
    end

  end

  class Condition

    TAG_NAMES = %w{ condition }

    attr_reader :property, :value, :items

    def initialize(attributes)
      @items = []
      @property = attributes['name']
      @value = attributes['value']
    end

    def add(item)
      case item
        when AIML::Tags::ListItem
          items.push item
        else
          li = AIML::Tags::ListItem.new('name' => property, 'value' => value)
          li.add(item)
          items.push li
      end
    end

    def to_s(context=nil)
      items.each do |item|
        p = property || item.attributes['name']
        v = (value || item.attributes['value']).gsub('*', '.*?')
        next unless context.get(p) =~ /^#{v}$/
        return item.to_s(context)
      end
      return ''
    end

    def inspect
      "condition -> #{conditions}"
    end

  end

  class ListItem

    TAG_NAMES = %w{ li }

    attr_reader :attributes, :template

    def initialize(attributes)
      @attributes = attributes
      @template = []
    end

    def add(body)
      template.push body
    end

    def to_s(context)
      result = ''
      template.each do |token|
        result += token.to_s(context)
      end
    end

  end

  class Question < Random

    TAG_NAMES = %w{ question }

    def initialize
      @items = [AIML::Tags::ReadOnlyTag.new('question')]
    end

  end

  class SetTag

    TAG_NAMES = [/^set_*/, 'set']

    attr_reader :local_name, :value

    def initialize(local_name, attributes)
      @local_name = attributes['name'] || local_name.sub(/^set_/, '')
      @value = []
    end

    def add(body)
      value.push(body)
    end

    def to_s(context)
      result = ''
      value.each { |token|
        result += token.to_s(context)
      }
      context.set(local_name, result.strip)
    end

    def inspect
      "set tag #{local_name} -> #{value}"
    end

  end

  class Input

    def initialize(attributes)
      @index = (attributes['index'] || 1).to_i
    end

    def to_s(context=nil)
      context.get_stimulus(@index)
    end

    def inspect
      "input stimulus[#{@index}]"
    end

  end

  class Star

    TAG_NAMES = %w{ topicstar thatstar star }

    attr_reader :star, :index

    def initialize(start_name, attributes={})
      @star = start_name
      @index = attributes['index'] ? attributes['index'].to_i - 1 : 0
    end

    def to_s(context=nil)
      context.send(star, index)
    end

    def inspect
      "#{star} #{index}"
    end

  end

  class ReadOnlyTag

    TAG_NAMES = [/^get.*/, /^bot_*/, 'for_fun', 'bot', 'name']

    attr_reader :name

    def initialize(local_name, attributes={})
      case local_name
        when 'that'
          @name = (attributes['index'] == '2,1') ? 'justbeforethat' : 'that'
        when 'get'
          @name = attributes['name']
        when 'bot'
          suffix = attributes["name"] || "name"
          @name = "bot_#{suffix}"
        else
          @name = local_name.sub(/^get_/, '')
      end
    end

    def to_s(context=nil)
      context.get(name)
    end

    def inspect
      "read only tag #{name}"
    end
  end

  class Think

    TAG_NAMES = %w{ think }

    attr_reader :thoughts

    def initialize
      @thoughts = []
    end

    def add(object)
      thoughts.push object
    end

    def to_s(context=nil)
      thoughts.each do |thought|
        thought.to_s(context)
      end
      return ''
    end

    def inspect
      "think status -> #{thoughts.map(&:inspect).join(' ')}"
    end
  end

  class Size
    def to_s(context=nil)
      Category.cardinality.to_s
    end

    def inspect
      "size -> #{Category.cardinality.to_s}"
    end
  end

  class Sys_Date
    def to_s(context=nil)
      Date.today.to_s
    end

    def inspect
      "date -> #{Date.today.to_s}"
    end
  end

  class Srai

    TAG_NAMES = %w{ srai  sr }

    def initialize(anObj=nil)
      @pattern = [anObj].compact
    end

    def add(anObj)
      @pattern.push(anObj)
    end

    def to_path(context)
      @pattern.map { |token| token.to_s(context).upcase.strip.split(/\s+/) }
    end

    def inspect
      "srai -> #{@pattern.map(&:inspect).join(' ')}"
    end

  end

  class Person2

    TAG_NAMES = %w{ person2 }

    PLACE_HOLDER = 'y-o-u'
    SWAP = {'me' => PLACE_HOLDER, 'i' => PLACE_HOLDER}
    SWAP_PARSER = /\b(#{SWAP.keys.join('|')})(\b|[^\w])/i

    YOU_PARSER = /\byou\b(\s*)(\b\w+\b)?/i

    attr_reader :sentence

    def initialize
      @sentence = []
    end

    def add(object)
      sentence.push(object)
    end

    def to_s(context=nil)
      result = ''
      sentence.each { |token|
        result += token.to_s(context)
      }
      result.gsub!(SWAP_PARSER) {
        SWAP[$1.downcase]
      }

      result.gsub!(YOU_PARSER) {
        space = $1
        next_word = $2
        if next_word && (TAGGER.add_tags(next_word) =~ /^<(md|v\w*)>#{next_word}/i)
          "i#{space}#{next_word}"
        else
          "me#{space}#{next_word}"
        end
      }

      result.gsub!(/#{PLACE_HOLDER}/, 'you')
    end

    def inspect
      "person2 -> #{sentence}"
    end
  end

  class Person

    TAG_NAMES = %w{ person }

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

    attr_reader :sentence

    def initialize
      @sentence = []
    end

    def add(object)
      sentence.push(object)
    end

    def to_s(context=nil)
      result = ''
      @sentence.each { |token|
        result += token.to_s(context)
      }
      gender = context.get('gender')
      result.gsub!(/\b(she|he|i|me|my|myself|mine)\b/i) {
        SWAP[gender][$1.downcase]
      }
      result
    end

    def inspect
      "person-> #{execute}"
    end
  end

  class Gender

    TAG_NAMES =%w{ gender }

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

    attr_accessor :sentence

    def initialize
      @sentence = []
    end

    def add(object)
      sentence.push(object)
    end

    def to_s(context=nil)
      result = ''
      sentence.each { |token|
        result += token.to_s(context)
      }
      result.gsub!(PRONOUN_PARSER) { PRONOUN_MAP[$1.downcase] }
      result.gsub!(HIS_HER_PARSER) {
        pronoun = $1.downcase
        space = $2
        next_word = $3
        if next_word && (TAGGER.add_tags(next_word) =~ /^<n\w+>#{next_word}/i)
          "#{POSSESIVE_MAP[pronoun]}#{space}#{next_word}"
        else
          "#{NOUN_MAP[pronoun]}#{space}#{next_word}"
        end
      }
      result
    end

    def inspect
      "gender -> #{sentence}"
    end
  end

  class Command

    TAG_NAMES = %w{ system }

    attr_reader :command

    def initialize(text=nil)
      @command = [text].compact
    end

    def add(body)
      command.push body
    end

    def to_s(context)
      cmd = command.map { |token| token.to_s(context) }.join
      `#{cmd}`.strip
    end

    def inspect
      "cmd -> #{command.map(&:inspect).join(' ')}"
    end
  end

end #AIML
