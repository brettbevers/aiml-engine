require_relative 'environment'

module AimlEngine

class Category
  attr_accessor :template, :that, :topic

  @@cardinality = 0
  def initialize 
    @@cardinality += 1 
    @pattern = []
    @that    = []
  end
  
  def Category.cardinality; @@cardinality end

  def add_pattern(anObj)
    @pattern.push(anObj)
  end

  def add_that(anObj)
    @that.push(anObj)
  end

  def get_pattern
    res = ''
    @pattern.each{|token|
      res += token.to_s
    }
    return res.split(/\s+/)
  end
  
  def get_that
    res = ''
    @that.each{|token|
      res += token.to_s
    }
    return res.split(/\s+/)
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
    @value << object
  end

  def append(text)
    text.strip.split(/\s+/).each( &method(:add) )
  end

  def inspect
    res = ''
    @value.each{|token| res += token.inspect }
    res
  end
end

class Random

  attr_reader :conditions

  def initialize
    @conditions = []
  end

  def setListElement(attributes)
    conditions.push([])
  end
  
  def add(body)
    conditions[-1].push(body)
  end

  def execute(context=nil)
    result = ''
    context.get_random(conditions).each{|token|
      result += token.to_s
    }
    return result.strip
  end
  alias to_s execute

  def inspect
    "random -> #{conditions}"
  end
end

class Condition
  #se c'e' * nel value?
  @@environment = Environment.new
  
  def initialize(attributes)
    @conditions = {}
    @property = attributes['name']
    @currentCondition = attributes['value'].sub('*','.*')
  end
  
  def add(aBody)
    unless @conditions[@currentCondition]
      @conditions[@currentCondition] = []
    end
    @conditions[@currentCondition].push(aBody)
  end

  def setListElement(attributes)
    @property = attributes['name'] if(attributes.key?('name'))
    @currentCondition = '_default'
    if(attributes.key?('value'))
      @currentCondition = attributes['value'].sub('*','.*')
    end
  end
  
  def execute(context=nil)
    return '' unless(@@environment.get(@property) =~ /^#{@currentCondition}$/)
    res = ''
    @conditions[@currentCondition].each{|token|
      res += token.to_s
    }
    return res.strip
  end
  alias to_s execute

  def inspect()
    "condition -> #{execute}" 
  end
end

class ListCondition < Condition
  def initialize(attributes)
    @conditions = {}
    @property = attributes['name'] if(attributes.key?('name'))
  end
  
  def execute(context=nil)
    @conditions.keys.each do |key|
      if(@@environment.get(@property) == key)
        res = ''
        @conditions[key].each{|token|
        res += token.to_s
      }
      return res.strip
      end
    end
    return ''
  end
  alias to_s execute
end

class SetTag

  attr_reader :local_name

  def initialize(local_name, attributes)
    if(attributes.empty?)
      @local_name = local_name.sub(/^set_/,'')
    else
      @local_name = attributes['name']
    end
    @value = []
  end
  
  def add(body)
    @value.push(body)
  end
  
  def execute(context=nil)
    result = ''
    @value.each{|token|
      result += token.to_s
    }
    context.set(@local_name,result.strip)
  end
  alias to_s execute

  def inspect
    "set tag #{@local_name}"
  end

end

class Input

  def initialize(attributes)
    @index = (attributes['index'] || 1).to_i
  end
  
  def execute(context=nil)
    context.get_stimulus(@index)
  end
  alias to_s execute

  def inspect
    "input stimulus[#{@index}]"
  end

end

class Star

  attr_reader :star, :index

  def initialize(start_name, attributes)
    @star = start_name
    @index = (attributes['index'] || 1).to_i - 1
  end
  
  def execute(context=nil)
    context.send(star, index)
  end
  alias to_s execute

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
  
  def execute(context=nil)
    context.get(name)
  end
  alias to_s execute

  def inspect
    "read only tag #{local_name}"
  end
end

class Think
  def initialize(aStatus)
    @status = aStatus
  end

  def execute(context=nil)
    @status
  end
  alias to_s execute

  def inspect
    "think status -> #{@status}"
  end
end

class Size
  def execute(context=nil)
    Category.cardinality.to_s
  end
  alias to_s execute

  def inspect
    "size -> #{Category.cardinality.to_s}"
  end
end

class Sys_Date
  def execute(context=nil)
    Date.today.to_s
  end
  alias to_s execute

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

  def to_path
    @pattern.map(&:to_s)
  end

  def inspect
    "srai -> #{@pattern}"
  end

end

class Person2
  @@swap = {'me' => 'you', 'you' => 'me'}
  def initialize
    @sentence = []
  end
  def add(anObj)
    @sentence.push(anObj)
  end
  def execute(context=nil)
    res = ''
    @sentence.each{|token|
      res += token.to_s
    }
    gender = context.get('gender')
    res.gsub(/\b((with|to|of|for|give|gave|giving) (you|me)|you|i)\b/i){
      if($3)
        $2.downcase+' '+@@swap[$3.downcase]
      elsif($1.downcase == 'you')
        'i'
      elsif($1.downcase == 'i')
        'you'
      end
    }
  end
  alias to_s execute
  def inspect(); "person2 -> #{execute}" end
end

class Person
  @@swap = {'male' => {'me'     => 'him',
                       'my'     => 'his', 
                       'myself' => 'himself', 
                       'mine'   => 'his', 
                       'i'      => 'he', 
                       'he'     => 'i', 
                       'she'    => 'i'},
            'female' => {'me'   => 'her', 
                         'my'     => 'her', 
                         'myself' => 'herself',
	                       'mine'   => 'hers',
                         'i'      => 'she',
                         'he'     => 'i',
                         'she'    => 'i'}}

  def initialize; @sentence = [] end
  def add(anObj); @sentence.push(anObj) end
  def execute(context=nil)
    res = ''
    @sentence.each{|token|
      res += token.to_s
    }
    gender = context.get('gender')
    res.gsub(/\b(she|he|i|me|my|myself|mine)\b/i){
      @@swap[gender][$1.downcase]
    }
  end
  alias to_s execute
  def inspect(); "person-> #{execute}" end
end

class Gender
  def initialize; @sentence = [] end
  def add(anObj); @sentence.push(anObj) end
  def execute(context=nil)
    res = ''
    @sentence.each{|token|
      res += token.to_s
    }
    res.gsub(/\b(she|he|him|his|(for|with|on|in|to) her|her)\b/i){

    pronoun = $1.downcase
      if(pronoun == 'she')
        'he'
      elsif(pronoun ==  'he')
        'she'
      elsif(pronoun ==  'him' || pronoun ==  'his')
        'her'
      elsif(pronoun ==  'her')
        'his'
      else
        $2.downcase + ' ' + 'him'
      end
    }
  end
  alias to_s execute
  def inspect(); "gender -> #{execute}" end
end

class Command

  attr_reader :command

  def initialize(text)
    @command = text
  end

  def execute(context)
    `#{command}`.strip
  end
  alias to_s execute

  def inspect
    "cmd -> #{command}"
  end
end

end #AimlEngine
