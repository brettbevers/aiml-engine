require 'yaml'

module AIML
  class History

    attr_accessor :topic
    attr_reader :inputs, :responses, :environment, :properties, :reactions, :graph_masters

    def initialize(attrs={})
      @topic          = attrs[:topic]           || [AIML::DEFAULT]
      @inputs         = attrs[:inputs]          || Array.new
      @responses      = attrs[:responses]       || Array.new
      @reactions      = attrs[:reactions]       || Array.new
      @graph_masters  = attrs[:graph_masters]   || Array.new
      @environment    = attrs[:environment]     || Hash.new
      @properties     = attrs[:properties]      || Hash.new
    end

    def dump
      {
          topic: topic,
          inputs: inputs,
          responses: responses,
          reactions: reactions,
          environment: environment,
          properties: properties
      }
    end

    def load_properties(new_properties)
      properties.merge!(new_properties)
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

    def get_property(tag)
      tag = tag.to_s
      if properties.key?(tag)
        properties[tag]
      else
        AIML::UNKNOWN
      end
    end

    def get_variable(tag)
      tag = tag.to_s
      if tag == 'topic'
        topic
      elsif environment.key?(tag)
        environment[tag]
      else
        AIML::UNKNOWN
      end
    end

    def set(tag, value)
      case tag
        when 'topic'
          self.topic = AIML::Tags::Pattern.process(value)
        else
          environment[tag.to_s] = value
      end
      return value
    end

    def that(index=1)
      responses[index-1] || UNDEF
    end

    def star(index)
      index -= 1
      return UNDEF unless star_greedy[index]
      star_greedy[index].map{|token| token.to_s(self)}.join(' ')
    end

    def thatstar(index)
      index -= 1
      return UNDEF unless that_greedy[index]
      that_greedy[index].map{|token| token.to_s(self)}.join(' ')
    end

    def topicstar(index)
      index -= 1
      return UNDEF unless topic_greedy[index]
      topic_greedy[index].map{|token| token.to_s(self)}.join(' ')
    end

    def male
      environment[:gender] = 'male'
    end

    def female
      environment[:gender] = 'female'
    end

    def update_response(sentences)
      responses.unshift(sentences)
    end

    def update_input(sentences)
      inputs.unshift(sentences)
    end

    def get_stimulus(index)
      inputs[index]
    end

  end
end

