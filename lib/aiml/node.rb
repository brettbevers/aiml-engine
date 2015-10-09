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
      children.each_key{|c| str += children[c].inspectNode(c, ind+1)}
      str
    end

    def learn(category, path)
      branch = path.shift
      return @template = category.template unless branch
      children[branch].learn(category, path)
    end

    def get_reaction(pattern, options={})
      reaction = _get_reaction(pattern, options)
      filter_reaction(reaction, options)
    end

    private

    def _get_reaction(pattern, options={})
      yield self if block_given?

      if pattern.satisfied?(children)
        return template ? Reaction.new(template) : nil
      end

      if children.key?("_") && pattern.key_matchable?
        reaction, index = search_suffixes(pattern, children["_"], greedy: true)
        if reaction
          reaction.add_match_group(pattern.current_segment, pattern.path[0...index])
          return reaction
        elsif t = children["_"].template
          reaction = Reaction.new(template)
          reaction.add_match_group(pattern.current_segment, pattern.stimulus)
          return reaction
        end
      end

      if children.key?(pattern.key)
        reaction = children[pattern.key].get_reaction(pattern.suffix)
        return reaction if reaction
      end

      if sets.any?
        sets.each do |set|
          matches = set.match(pattern)
          next unless matches.any?
          matches.each do |index, match|
            reaction = children[set].get_reaction(pattern.suffix(index))
            if reaction
              reaction.add_match_group(pattern.current_segment, match)
              return reaction
            end
          end
        end
      end

      if children.key?("*") && pattern.key_matchable?
        reaction, index = search_suffixes(pattern, children["*"])
        if reaction
          reaction.add_match_group(pattern.current_segment, pattern.path[0...index])
          return reaction
        elsif t = children["*"].template
          reaction = Reaction.new(t)
          reaction.add_match_group(pattern.current_segment, pattern.stimulus)
          return reaction
        end
      end

      if pattern.start_that_segment?
        topic_segment = pattern.topic_segment
        reaction = get_reaction(topic_segment)
        return reaction if reaction
      end

      if pattern.start_topic_segment? && pattern.suffix.null_key? && template
        return Reaction.new(template)
      end

      return nil
    end

    def sets
      @sets ||= children.keys.select{|key| key.is_a? AIML::Tags::MatchSet }
    end

    def search_suffixes(pattern, graph, greedy: false)
      index = 1
      memo = pattern
      segment = pattern.current_segment
      current_reaction = nil
      current_index = nil
      while memo = memo.suffix and memo.current_segment == segment
        reaction = graph.get_reaction(memo)
        if reaction
          current_reaction = reaction
          current_index = index
        end
        return current_reaction, current_index if current_reaction && !greedy
        index += 1
      end
      return current_reaction, current_index
    end

    def filter_reaction(reaction, options={})
      return nil unless reaction
      if options[:exclude].is_a?(Array) and options[:exclude].includes?(reaction.template)
        nil
      else
        reaction
      end
    end

  end

end

