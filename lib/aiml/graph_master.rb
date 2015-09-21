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
      reaction.render(context) do |token|
        result.push render_token(token, context)
      end

      result.flatten.join.gsub(/\s+/,' ').strip
    end

    def render_token(token, context)
      case token
        when AIML::Tags::Srai
          render_reaction(token.to_pattern(context), context)
        when AIML::Tags::ListItem
          token.body.map{ |sub_token| render_token(sub_token, context) }
        when AIML::Tags::Condition, AIML::Tags::Random, AIML::Tags::Question
          render_token(token.get_item(context), context)
        when AIML::Tags::Think
          token.body.map{ |sub_token| render_token(sub_token, context) }
          return ''
        else
          token.to_s(context)
      end
    end

  end

end
