require 'yaml'

module AIML
  class History

    attr_accessor :topic
    attr_reader :inputs, :responses, :predicates, :properties, :reactions, :graph_masters, :scopes

    def initialize(attrs={})
      @topic          = attrs[:topic]           || [AIML::DEFAULT]
      @inputs         = attrs[:inputs]          || Array.new
      @responses      = attrs[:responses]       || Array.new
      @reactions      = attrs[:reactions]       || Array.new
      @graph_masters  = attrs[:graph_masters]   || Array.new
      @predicates     = attrs[:predicates]      || Hash.new
      @properties     = attrs[:properties]      || Hash.new
      @scopes         = attrs[:scopes]          || Array.new
    end

    def dump
      {
          topic: topic,
          inputs: inputs,
          responses: responses,
          reactions: reactions,
          predicates: predicates,
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

    def get_predicate(tag)
      tag = tag.to_s
      if tag == 'topic'
        topic
      elsif predicates.key?(tag)
        predicates[tag]
      else
        AIML::UNKNOWN
      end
    end

    def get_variable(tag)
      raise AIML::NoOpenScope unless current_scope
      tag = tag.to_s
      if current_scope.key?(tag)
        return current_scope[tag]
      else
        AIML::UNKNOWN
      end
    end

    def set_predicate(tag, value)
      case tag
        when 'topic'
          self.topic = AIML::Tags::Pattern.process(value)
        else
          predicates[tag.to_s] = value
      end
      return value
    end

    def set_variable(tag, value)
      raise AIML::NoOpenScope unless current_scope
      current_scope[tag.to_s] = value
    end

    def current_scope
      scopes.first
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
      predicates[:gender] = 'male'
    end

    def female
      predicates[:gender] = 'female'
    end

    def update_response(sentences)
      copy = Marshal.load(Marshal.dump(sentences))
      responses.unshift(copy)
    end

    def update_input(sentences)
      copy = Marshal.load(Marshal.dump(sentences))
      inputs.unshift(copy)
    end

    def get_stimulus(index)
      inputs[index]
    end

    def scoped
      scopes.unshift Hash.new
      result = yield if block_given?
      scopes.shift
      result
    end

  end
end

