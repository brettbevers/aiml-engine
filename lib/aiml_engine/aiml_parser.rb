require 'rexml/parsers/sax2parser'
require_relative 'aiml_elements'

# gli accenti nel file di input vengono trasformati in &apos; !!!
#
module  AimlEngine
class AimlParser
  def initialize(learner)
    @learner = learner
  end

  def parse(aiml)
    @parser = REXML::Parsers::SAX2Parser.new(aiml)
    openLabels       = []
    currentPerson    = nil
    currentPerson2   = nil
    currentTopic     = nil

    @parser.listen(%w{ category }){|uri,local_name,qname,attributes|
      openLabels.push Category.new(currentTopic || attributes['topic'])
    }

    @parser.listen(['topicstar','thatstar','star']){|u,local_name,qn,attributes|
      openLabels[-1].add(Star.new(local_name, attributes))
    }

### condition -- random
    @parser.listen(%w{ condition }){|uri,local_name,qname,attributes|
      currentCondition = Condition.new(attributes)
      openLabels[-1].add(currentCondition)
      openLabels.push(currentCondition)
    }
    
    @parser.listen(%w{ random }){|uri,local_name,qname,attributes|
      currentCondition = Random.new
      openLabels[-1].add(currentCondition)
      openLabels.push(currentCondition)
    }
    
    @parser.listen(:characters, %w{ condition }){|text|
      openLabels[-1].add(text) unless text =~ /^\s+$/
    }

    @parser.listen(%w{ li }){|uri,local_name,qname,attributes|
      openLabels.push ListItem.new(openLabels[-1], attributes)
    }
    
    @parser.listen(:characters,%w{ li }){|text|
      openLabels[-1].add(text)
    }

    @parser.listen(:end_element, %w{ li }){
      openLabels.pop.add_to_list
    }

    @parser.listen(:end_element, %w{ condition random }){
      openLabels.pop
    }
### end condition -- random

    @parser.listen([/^get.*/, /^bot_*/,'for_fun']){ |uri,local_name,qname,attributes|
      unless(openLabels.empty?)
        openLabels[-1].add(ReadOnlyTag.new(local_name, attributes))
      end
    }

    @parser.listen(%w{ question }){|uri,local_name,qname,attributes|
      new_random = Random.new
      new_random.choices = ReadOnlyTag.new(local_name, attributes)
      openLabels[-1].add(new_random)
    }

    @parser.listen(['bot','name']){|uri,local_name,qname,attributes|
      if local_name == 'bot'
        local_name = 'bot_'+attributes['name']
      else
        local_name = 'bot_name'
      end
      openLabels[-1].add(ReadOnlyTag.new(local_name, {}))
    }

### set
    @parser.listen([/^set_*/,'set']){|uri,local_name,qname,attributes|
      setObj = SetTag.new(local_name,attributes)
      openLabels[-1].add(setObj)
      openLabels.push(setObj)
    }

    @parser.listen(:characters,[/^set_*/]){|text|
      openLabels[-1].add(text)    
    }

    @parser.listen(:end_element, [/^set_*/,'set']){
      openLabels.pop      
    }
### end set

### pattern
    @parser.listen(%w{ pattern }){
      new_pattern = Pattern.new
      openLabels[-1].pattern = new_pattern
      openLabels.push new_pattern
    }
    @parser.listen(:characters,%w{ pattern }){|text|
      openLabels[-1].add(text)
    }
    @parser.listen(:end_element, %w{ pattern }){
      openLabels.pop
    }
### end pattern

#### that
    @parser.listen(%w{ that }){ |uri,local_name,qname,attributes|
      new_that = That.new
      case openLabels[-1]
        when Category
          openLabels[-1].that = new_that
        else
          openLabels[-1].add(ReadOnlyTag.new(local_name, attributes))
      end
      openLabels.push new_that
    }
    @parser.listen(:characters,%w{ that }){|text|
      openLabels[-1].add(text)
    }
    @parser.listen(:end_element, %w{ that }){
      openLabels.pop
    }
### end that

### template
    @parser.listen(%w{ template }){
      new_template = Template.new
      openLabels[-1].template = new_template
      openLabels.push(new_template)
    }

    @parser.listen(:characters, %w{ template }){|text|
      openLabels[-1].add(text)
    }

    @parser.listen(:end_element, %w{ template }){
      openLabels.pop
    }
### end template

    @parser.listen(%w{ br }){
      openLabels[-1].add("\n")
    }

    @parser.listen(%w{ input }){|uri,local_name,qname,attributes|
      openLabels[-1].add(Input.new(attributes))
    }

### think
    @parser.listen(:start_element, %w{ think }){
      openLabels[-1].add(Think.new('start'))
    }

    @parser.listen(:end_element, %w{ think }){
    openLabels[-1].add(Think.new('end'))
    }
###end think

    @parser.listen(:characters, %w{ uppercase }){|text|
      openLabels[-1].add(text.upcase.gsub(/\s+/, ' '))
    }

    @parser.listen(:characters, %w{ lowercase }){|text|
      openLabels[-1].add(text.downcase.gsub(/\s+/, ' '))
    }

    @parser.listen(:characters, %w{ formal }){|text|
      text.gsub!(/(\w+)/){$1.capitalize}
      openLabels[-1].add(text.gsub(/\s+/, ' '))
    }

    @parser.listen(:characters, %w{ sentence }){|text|
      openLabels[-1].add(text.capitalize.gsub(/\s+/, ' '))
    }

    @parser.listen(%w{ date }){
      openLabels[-1].add(Sys_Date.new)
    }
    
    @parser.listen(:characters, %w{ system }){|text|
      openLabels[-1].add(Command.new(text))
    }
    
    @parser.listen(%w{ size }){ 
      openLabels[-1].add(Size.new)
    }

    @parser.listen(%w{ sr }){|uri,local_name,qname,attributes|
      openLabels[-1].add(Srai.new(Star.new('star',{})))
    }
### srai    
    @parser.listen(%w{ srai }){|uri,local_name,qname,attributes|
      currentSrai = Srai.new
      openLabels[-1].add(currentSrai)
      openLabels.push(currentSrai)
    }
    
    @parser.listen(:characters, %w{ srai }){|text|



      openLabels[-1].append(text)
    }
    
    @parser.listen(:end_element, %w{ srai }){
      currentSrai = nil
      openLabels.pop
    }
### end srai

### gender
    @parser.listen(%w{ gender }){|uri,local_name,qname,attributes|
      new_gender = Gender.new
      openLabels[-1].add(new_gender)
      openLabels.push(new_gender)
    }
    
    @parser.listen(:characters, %w{ gender }){|text|
      openLabels[-1].add(text)
    }

    @parser.listen(:end_element, %w{ gender }){
      currentGender = nil
      openLabels.pop
    }
### end gender

### person
    @parser.listen(%w{ person }){|uri,local_name,qname,attributes|
      currentPerson = Person.new
      openLabels[-1].add(currentPerson)
      openLabels.push(currentPerson)
    }
    
    @parser.listen(:characters, %w{ person }){|text|
      currentPerson.add(text)
    }

    @parser.listen(:end_element, %w{ person }){
      currentPerson = nil
      openLabels.pop
    }
### end person

### person2
    @parser.listen(%w{ person2 }){|uri,local_name,qname,attributes|
      currentPerson2 = Person2.new
      openLabels[-1].add(currentPerson2)
      openLabels.push(currentPerson2)
    }
    
    @parser.listen(:characters, %w{ person2 }){|text|
      currentPerson2.add(text)
    }

    @parser.listen(:end_element, %w{ person2 }){
      currentPerson2 = nil
      openLabels.pop
    }
### end person2

    @parser.listen(:end_element, %w{ category }){
      @learner.learn(openLabels.pop)
    }

### topic
    @parser.listen(%w{ topic }){|uri,local_name,qname,attributes|
      currentTopic = attributes['name']
    }
    
    @parser.listen(:end_element, %w{ topic }){
      currentTopic = nil
    }
### end topic

    @parser.parse
  end
end #Aiml@parser
end
