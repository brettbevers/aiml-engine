require_relative '../aiml_engine'
require_relative 'aiml_elements'
require_relative 'node'

module AIML

  class GraphMaster
    attr_reader :graph, :sets, :maps, :normalizer, :denormalizer, :char_aliases

    CHAR_ALIASES = {
        '*' => ' star ',
        '#' => ' sharp ',
        '$' => ' dollarsign ',
        '_' => ' underscore ',
        '^' => ' uparrow '
    }

    def initialize
      @graph        = Node.new
      @sets         = Node.new
      @maps         = Node.new
      @normalizer   = Node.new
      @denormalizer = Node.new
      @char_aliases = CHAR_ALIASES.dup
    end

    def merge(aCache)
      graph.merge(aCache.graph)
    end

    def learn(category)
      graph.learn(category)
    end

    def learn_set_element(element)
      sets.learn(element)
    end

    def learn_map_element(element)
      maps.learn(element)
    end

    def learn_normalizer_element(element)
      @normalizer.learn(element)
    end

    def learn_denormalizer_element(element)
      @denormalizer.learn(element)
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
      context.reactions.push reaction
      context.graph_masters.push self
      result = reaction.to_s(context)
      context.reactions.pop
      context.graph_masters.pop
      result
    end

    def normalize(str)
      return unless str
      char_aliases.each do |k,v|
        str = str.gsub(k,v)
      end
      str = str.upcase

      path = AIML::SubstitutionElement.process(str)
      result = []
      until path.empty?
        pattern = AIML::Tags::Pattern.new(path: path)
        reaction = normalizer.get_reaction(pattern)
        if reaction
          result += reaction.template.body
          path = path[reaction.depth..-1]
        else
          result << path.shift
        end
      end
      result.flatten.join
    end

    def denormalize(str)
      return unless str
      path = AIML::SubstitutionElement.process(str)
      result = []
      until path.empty?
        pattern = AIML::Tags::Pattern.new(path: path)
        reaction = denormalizer.get_reaction(pattern)
        if reaction
          result += reaction.template.body
          path = path[reaction.depth..-1]
        else
          result << path.shift
        end
      end
      result.flatten.join
    end

  end

end
