require 'yaml'

module AIML
  class History

    DEFAULT_ATTRIBUTES = YAML::load(File.open(File.dirname(__FILE__) + "/../../conf/readOnlyTags.yaml"))

    attr_accessor :topic
    attr_reader :inputs, :responses, :environment, :reactions

    def initialize(attrs={})
      @topic = attrs[:topic] || AIML::DEFAULT
      @inputs = attrs[:inputs] || []
      @responses = attrs[:responses] || []
      @reactions = attrs[:reactions] || []
      @environment = attrs[:environment] || DEFAULT_ATTRIBUTES.dup
    end

    def star_greedy
      return [] unless @reactions[-1]
      @reactions[-1].star
    end

    def that_greedy
      return [] unless @reactions[-1]
      @reactions[-1].that_star
    end

    def topic_greedy
      return [] unless @reactions[-1]
      @reactions[-1].topic_star
    end

    def get(tag)
      tag = tag.to_s
      if environment.key?(tag)
        environment[tag]
      elsif tag =~ /that$/
        send(tag)
      elsif tag == 'topic'
        topic
      else
        ''
      end
    end

    def set(tag, value)
      case tag
        when 'topic'
          self.topic = value
        else
          environment[tag.to_s] = value
      end
      return value
    end

    def that(index=1)
      responses[index-1] || UNDEF
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

    def star(index)
      index -= 1
      return UNDEF unless star_greedy[index]
      star_greedy[index].join(' ')
    end

    def thatstar(index)
      index -= 1
      return UNDEF unless that_greedy[index]
      that_greedy[index].join(' ')
    end

    def topicstar(index)
      index -= 1
      return UNDEF unless topic_greedy[index]
      topic_greedy[index].join(' ')
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

    def get_random(choices)
      choices[rand(choices.length)]
    end

    def update_response(response)
      responses.unshift(response)
    end

    def update_stimulus(raw_stimulus)
      inputs.unshift(raw_stimulus)
    end

    def get_stimulus(index)
      inputs[index]
    end

    def with_reaction(reaction)
      reactions.push reaction
      yield
      reactions.pop
    end

  end
end

