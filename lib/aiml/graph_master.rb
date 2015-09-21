require_relative '../aiml_engine'
require_relative 'aiml_elements'
require_relative 'node'

module AIML

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

    def render_reaction(pattern, context)
      reaction = get_reaction(pattern)
      return unless reaction

      result = []
      context.reactions.push reaction
      context.graph_masters.push self
      reaction.template.each do |token|
        result.push token.to_s(context)
      end
      context.reactions.pop
      context.graph_masters.pop

      result.flatten.join.gsub(/\s+/,' ').strip
    end

  end

end
