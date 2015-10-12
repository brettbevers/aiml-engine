require_relative '../aiml_engine'
require_relative 'aiml_elements'
require_relative 'node'

module AIML

  class GraphMaster
    attr_reader :graph
    attr_accessor :sets

    def initialize
      @graph = Node.new
      @sets  = Node.new
    end

    def merge(aCache)
      graph.merge(aCache.graph)
    end

    def learn(category)
      graph.learn(category, category.path.dup)
    end

    def learn_set_element(element)
      sets.learn(element, element.path.dup)
    end

    def to_s
      graph.inspectNode
    end

    def get_reaction(pattern)
      graph.get_reaction(pattern)
    end

    def render_reaction(pattern, context)
      reaction = get_reaction(pattern)
      render(reaction, context).join.gsub(/\s+/,' ').strip if reaction
    end

    def match_set(pattern)
      sets.get_reaction(pattern)
    end

    def render(reaction, context=AIML::History.new)
      result = []
      context.reactions.push reaction
      context.graph_masters.push self
      reaction.template.each do |token|
        result.push token.to_s(context)
      end
      context.reactions.pop
      context.graph_masters.pop
      result.flatten
    end

  end

end
