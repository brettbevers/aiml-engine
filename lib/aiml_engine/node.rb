require_relative 'reaction'

module AimlEngine

  class Node
    attr_reader :children
    attr_accessor :template

    def initialize
      @template = Template.new
      @children = {}
    end

    def inspectNode(nodeId = nil, ind = 0)
      str = ''
      str += '| '*(ind - 1) + "|_#{nodeId}" unless ind == 0
      str += ": [#{@template.inspect}]" if @template
      str += "\n" unless ind == 0
      @children.each_key{|c| str += @children[c].inspectNode(c, ind+1)}
      str
    end

    def merge(aCache)
      aCache.children.keys.each do |key|
        if(@children.key?(key))
          @children[key].merge(aCache.children[key])
          next
        end
        @children[key] = aCache.children[key]
      end
    end

    def learn(category, path)
      branch = path.shift
      return @template = category.template unless branch
      @children[branch] = Node.new unless @children[branch]
      @children[branch].learn(category, path)
    end

    def get_reaction(pattern)
      return Reaction.new(template) if pattern.satisfied?(children)

      if pattern.start_that_segment? && !children.key?(THAT)
        topic_segment = pattern.topic_segment
        reaction = get_reaction(topic_segment)
        return reaction if reaction
      end

      if @children.key?("_") && pattern.key_matchable?
        reaction, index = search_suffixes(pattern, @children["_"])
        return reaction if reaction
      end

      if @children.key?(pattern.key)
        reaction = @children[pattern.key].get_reaction(pattern.suffix)
        if reaction
          return reaction
        elsif pattern.start_context_segment? && pattern.suffix.null_key?
          return Reaction.new(template)
        end
      end

      if @children.key?("*") && pattern.key_matchable?
        reaction, index = search_suffixes(pattern, @children["*"])
        if reaction
          reaction.match_group = pattern.path[0...index]
          return reaction
        else
          return Reaction.new(template, pattern.stimulus)
        end
      end

      return nil
    end

    private

    def search_suffixes(pattern, graph)
      pattern.suffixes.each do |index, suffix|
        reaction = graph.get_reaction(suffix)
        return reaction, index if reaction
      end
      return nil
    end

  end

end

