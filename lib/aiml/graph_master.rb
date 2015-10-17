require_relative '../aiml_engine'
require_relative 'aiml_elements'
require_relative 'node'

module AIML

  class GraphMaster
    attr_reader :graph, :sets, :maps

    def initialize
      @graph = Node.new
      @sets  = Node.new
      @maps  = Node.new
    end

    def merge(aCache)
      graph.merge(aCache.graph)
    end

    def learn(category)
      graph.learn(category, category.path)
    end

    def learn_set_element(element)
      sets.learn(element, element.path)
    end

    def learn_map_element(element)
      maps.learn(element, element.path)
    end

    def to_s
      graph.inspectNode
    end

    def render_reaction(pattern, context)
      AIML::Node.with_context(context) do
        reaction = graph.get_reaction(pattern)
        render(reaction, context) if reaction
      end
    end

    def match_set(pattern)
      sets.get_reaction(pattern)
    end

    def map(pattern, context)
      AIML::Node.with_context(context) do
        reaction = maps.get_reaction(pattern)
        reaction ? render(reaction, context) : AIML::UNKNOWN
      end
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
      result.flatten.join.gsub(/\s+/,' ').strip
    end

  end

end
