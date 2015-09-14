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

      @graph.learn(category, category.path.dup)
    end

    def to_s
      graph.inspectNode
    end

    def get_reaction(pattern)
      graph.get_reaction(pattern)
    end

    def render_reaction(pattern, context, thinking: false)
      reaction = get_reaction(pattern)

      result = []

      reaction.render(context) do |token|
        case token
          when Srai
            stimulus = token.to_path(context)
            path = [stimulus, THAT, process_string(context.that), TOPIC, process_string(context.topic)].flatten
            next_pattern = Pattern.new(path: path, stimulus: stimulus, that: context.that, topic: context.topic)
            result << render_reaction(next_pattern, context, thinking: thinking)
          when Think
            thinking = !thinking
          else
            r = token.to_s(context)
            result << r unless thinking
        end
      end

      result.join.gsub(/\s+/,' ').strip
    end

    private

    def process_string(str)
      return unless str
      str.strip.upcase.split(/\s+/)
    end

  end

end
