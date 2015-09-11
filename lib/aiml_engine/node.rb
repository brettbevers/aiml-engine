require_relative 'reaction'

module AimlEngine

  THAT  = '<that>'
  TOPIC = '<topic>'

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

    def get_reaction(path)
      return Reaction.new(template) if remove_context_from_path(path).empty?

      if @children.key?("_")
        reaction, index = search_suffixes(path[1..-1], @children["_"])
        return reaction if reaction
      end

      if @children.key?(path[0])
        reaction = @children[path[0]].get_reaction(path[1..-1])
        return reaction if reaction
      end

      if @children.key?("*")
        reaction, index = search_suffixes(path[1..-1], @children["*"])
        if reaction
          reaction.match_group = remove_context_from_path(path)[0...index]
          return reaction
        else
          binding.pry
          return Reaction.new(template, remove_context_from_path(path))
        end
      end

      return nil
    end

    private

    def search_suffixes(path, graph)
      (0...path.size).each do |index|
        reaction = graph.get_reaction(path[index..-1])
        return reaction, index if reaction
      end
      return nil
    end

    def remove_context_from_path(path)
      that_index = path.index(THAT)
      return [] if that_index == 0
      topic_index =  path.index(TOPIC)
      return [] if topic_index == 0
      return path if that_index.nil? && topic_index.nil?
      limit = [that_index, topic_index].compact.min
      return path[0...limit]
    end

  end

end

