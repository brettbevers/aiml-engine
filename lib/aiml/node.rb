require_relative 'reaction'

module AIML

  class Node
    attr_reader :children
    attr_accessor :template

    def initialize
      @children = Hash.new { |hash, key| hash[key] = Node.new }
    end

    def inspectNode(nodeId = nil, ind = 0)
      str = ''
      str += '| '*(ind - 1) + "|_#{nodeId}" unless ind == 0
      str += ": [#{@template.inspect}]" if @template
      str += "\n" unless ind == 0
      @children.each_key{|c| str += @children[c].inspectNode(c, ind+1)}
      str
    end

    # def merge(aCache)
    #   aCache.children.keys.each do |key|
    #     if(@children.key?(key))
    #       @children[key].merge(aCache.children[key])
    #       next
    #     end
    #     @children[key] = aCache.children[key]
    #   end
    # end

    def learn(category, path)
      branch = path.shift
      return @template = category.template unless branch
      @children[branch].learn(category, path)
    end

    def get_reaction(pattern)
      binding.pry if $really_stop

      if pattern.satisfied?(children)
        return template ? Reaction.new(template) : nil
      end

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
        elsif template && pattern.start_context_segment? && pattern.suffix.null_key?
          return Reaction.new(template)
        end
      end

      if @children.key?("*") && pattern.key_matchable?
        reaction, index = search_suffixes(pattern, @children["*"])
        if reaction
          reaction.add_match_group(pattern.current_segment, pattern.path[0...index])
          return reaction
        elsif template
          reaction = Reaction.new(template)
          reaction.add_match_group(pattern.current_segment, pattern.stimulus)
        end
        return reaction
      end

      return nil
    end

    private

    def search_suffixes(pattern, graph)
      index = 1
      memo = pattern
      segment = pattern.current_segment
      while memo = memo.suffix and memo.current_segment == segment
        reaction = graph.get_reaction(memo)
        return reaction, index if reaction
        index += 1
      end
      return nil
    end

  end

end

