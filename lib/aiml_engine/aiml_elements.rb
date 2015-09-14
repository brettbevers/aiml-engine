require_relative 'pattern'

module AimlEngine

  class That

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
    result += [THAT, that.path] if that
    result += [TOPIC, topic]    if topic
    result.flatten
  end

end

class Template
  attr_accessor :value

  def map(&block)
    value.map(&block)
  end

  def each(&block)
    value.each(&block)
  end

  def initialize
    @value = []
  end

  def add(object)
    value << object
  end

  def append(text)
    text.strip.split(/\s+/).each( &method(:add) )
  end

  def inspect
    result = ''
    value.each{|token| result += token.inspect }
    result
  end
end

class Random

  attr_accessor :choices

  def initialize
    @choices = []
  end

  def add(body, attributes={})
    if body.is_a?(Array)
      choices.push body
    else
      choices.push [body]
    end
  end

  def to_s(context=nil)
    result = ''

    case choices
      when Array
        body = context.get_random(choices)
        body.each do |token|
          result += token.to_s(context)
        end
      else
        ary = choices.to_s(context)
        result += context.get_random( ary )
    end

    return result.strip
  end

  def inspect
    "random -> #{choices}"
  end

end

class Condition

  attr_reader :conditions, :property, :value

  def initialize(attributes)
    @conditions = Array.new
    @property = attributes['name']
    @value = attributes['value']
  end

  def add(body, attributes={})
    p   = attributes['name'] || property
    v   = attributes['value'] ? attributes['value'].gsub('*','.*') : value
    raise 'property or value missing' unless p and v
    if body.is_a?(Array)
      conditions.push([p,v,body])
    else
      conditions.push([p,v,[body]])
    end
  end

  def to_s(context=nil)
    result = ''
    conditions.each do |property, value, body|
      next unless context.get(property) =~ /^#{value}$/
      body.each do |token|
        result += token.to_s(context)
      end
    end
    return result.strip
  end

  def inspect
    "condition -> #{conditions}"
  end

end

class ListItem

  attr_reader :list, :attributes, :template

  def initialize(list, attributes)
    @list       = list
    @attributes = attributes
    @template   = []
  end

  def add(body)
    template.push body
  end

  def add_to_list
    list.add(template, attributes)
  end

end

class SetTag

  attr_reader :local_name, :value

  def initialize(local_name, attributes)
    @local_name = attributes['name'] || local_name.sub(/^set_/,'')
    @value = []
  end

  def add(body)
    value.push(body)
  end

  def to_s(context=nil)
    result = ''
    value.each{|token|
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

  attr_reader :star, :index

  def initialize(start_name, attributes)
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

  attr_reader :name

  def initialize(local_name, attributes)
    if attributes['index'] == '2,1' && local_name == 'that'
      @name = 'justbeforethat'
    elsif attributes['name']
      @name = attributes['name']
    else
      @name = local_name.sub(/^get_/, '')
    end
  end

  def to_s(context=nil)
    context.get(name)
  end

  def inspect
    "read only tag #{local_name}"
  end
end

class Think
  def initialize(aStatus)
    @status = aStatus
  end

  def to_s(context=nil)
    @status
  end

  def inspect
    "think status -> #{@status}"
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

  def initialize(anObj=nil)
    @pattern = [anObj].compact
  end

  def add(anObj)
    @pattern.push(anObj)
  end

  def append(text)
    text.strip.upcase.split(/\s+/).each(&method(:add))
  end

  def to_path(context)
    @pattern.map{ |token| token.to_s(context).upcase.strip.split(/\s+/) }
  end

  def inspect
    "srai -> #{@pattern}"
  end

end

class Person2
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
    sentence.each{|token|
      result += token.to_s(context)
    }
    result.gsub!(SWAP_PARSER){
      SWAP[$1.downcase]
    }

    result.gsub!(YOU_PARSER){
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
    @sentence.each{|token|
      result += token.to_s(context)
    }
    gender = context.get('gender')
    result.gsub!(/\b(she|he|i|me|my|myself|mine)\b/i){
      SWAP[gender][$1.downcase]
    }
    result
  end

  def inspect
    "person-> #{execute}"
  end
end

class Gender

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
    sentence.each{|token|
      result += token.to_s(context)
    }
    result.gsub!(PRONOUN_PARSER){ PRONOUN_MAP[$1.downcase] }
    result.gsub!(HIS_HER_PARSER){
      pronoun   = $1.downcase
      space     = $2
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

  attr_reader :command

  def initialize(text)
    @command = text
  end

  def to_s(context)
    `#{command}`.strip
  end

  def inspect
    "cmd -> #{command}"
  end
end

end #AimlEngine
