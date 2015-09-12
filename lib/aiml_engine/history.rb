module AimlEngine
class History

  DEFAULT_ATTRIBUTES = YAML::load(File.open(File.dirname(__FILE__) + "/../../conf/readOnlyTags.yaml"))

  attr_accessor :topic
  attr_reader :inputs, :responses, :star_greedy, :that_greedy, :topic_greedy, :environment
  
  def initialize(attrs={})
    @topic          = attrs[:topic]        || AimlEngine::DEFAULT
    @inputs         = attrs[:inputs]       || []
    @responses      = attrs[:responses]    || []
    @star_greedy    = attrs[:star_greedy]  || []
    @that_greedy    = attrs[:that_greedy]  || []
    @topic_greedy   = attrs[:topic_greedy] || []
    @environment    = DEFAULT_ATTRIBUTES
  end

  def get(tag)
    tag = tag.to_sym
    if environment.key?(tag)
      environment[tag]
    elsif tag =~ /that$/
      send(tag)
    else
      ''
    end
  end

  def set(tag, value)
    case tag
      when 'topic'
        self.topic = value
      else
        environment[tag.to_sym] = value
    end
  end
  
  def that
    responses[0] || UNDEF
  end
  
  def justbeforethat 
    responses[1] || UNDEF
  end
  
  def justthat 
    inputs[0] || UNDEF
  end
  
  def beforethat 
    inputs[1] || UNDEF
  end
  
  def star(anIndex)
    return UNDEF unless star_greedy[anIndex]
    star_greedy[anIndex].join(' ')
  end

  def thatstar(anIndex)
    return UNDEF unless that_greedy[anIndex]
    that_greedy[anIndex].join(' ') 
  end
  
  def topicstar(anIndex)
    return UNDEF unless topic_greedy[anIndex]
    topic_greedy[anIndex].join(' ')
  end

  def male
    environment[:gender] = 'male'
  end

  def female
    environment[:gender] = 'female'
  end

  def question
    get_random(environment[:question])
  end

  def get_random(anArrayofChoices)
    anArrayofChoices[rand(anArrayofChoices.length)]
  end

  def update_response(aResponse)
    responses.unshift(aResponse)
  end

  def update_stimulus(raw_stimulus)
    inputs.unshift(raw_stimulus)
  end

  def get_stimulus(anIndex)
    inputs[anIndex]
  end
  
  def updateStarMatches(aStarGreedyArray)
    @star_greedy = []
    @that_greedy = []
    @topicGreedy = []
    currentGreedy = star_greedy
    aStarGreedyArray.each do |greedy|
      if(greedy == '<that>')
        currentGreedy = that_greedy
      elsif(greedy == '<topic>')
        currentGreedy = topic_greedy
      elsif(greedy == '<newMatch>')
        currentGreedy.push([])
      else
        currentGreedy[-1].push(greedy)
      end
    end
  end

end
end

