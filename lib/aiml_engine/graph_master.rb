require_relative '../aiml_engine'
require_relative 'aiml_elements'
require_relative 'node'

module AimlEngine

  class GraphMaster
    attr_reader :graph

    def initialize
      @graph = Node.new
    end

    def merge(aCache)
      graph.merge(aCache.graph)
    end

    def learn(category)
      path = category.get_pattern
      path += [THAT] + category.get_that unless (category.get_that).empty?
      path += [TOPIC] + category.topic.split(/\s+/) if category.topic
      @graph.learn(category, path)
    end

    def to_s
      graph.inspectNode
    end

    def get_reaction(pattern)
      graph.get_reaction(pattern)
    end

    def render_reaction(pattern, context=nil, thinking: false)
      result = []
      reaction = get_reaction(pattern)
      template = reaction.render_template
      template.each { |token|
        case token
          when String
            result << token
          when Srai
            stimulus = token.to_path
            path = [stimulus, THAT, process_string(context.that), TOPIC, process_string(context.topic)].flatten
            next_pattern = Pattern.new(path: path, stimulus: stimulus, context: context)
            result << render_reaction(next_pattern, context, thinking: thinking)
          when Think
            thinking = !thinking
          else
            r = token.execute(context)
            result << r unless thinking
        end
      }
      result.join(' ')
    end

    private

    def process_string(str)
      return unless str
      str.strip.upcase.split(/\s+/)
    end
  end

end
