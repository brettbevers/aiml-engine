require_relative '../aiml_engine'
require_relative 'aiml_elements'
require_relative 'node'

module AimlEngine

  THAT  = '<that>'
  TOPIC = '<topic>'

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

    def get_reaction(path)
      graph.get_reaction(path)
    end

    def render_reaction(path, thinking=false)
      result = []
      reaction = get_reaction(path)
      template = reaction.render_template
      template.each { |token|
        case token
          when Srai
            binding.pry
            result << render_reaction(token.to_path)
          when Think
            thinking = !thinking
          else
            result << token.to_s unless thinking
        end
      }
      result.join(' ')
    end
  end

end
