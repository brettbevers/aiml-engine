require_relative 'reaction'

module AIML

  class Node
    attr_reader :children
    attr_accessor :template

    def initialize
      @children = Hash.new { |hash, key| hash[key] = Node.new }
    end

    def self.with_context(context)
      @@context = context
      result = nil
      result = yield if block_given?
    ensure
      @@context = nil
      result
    end

    def context
      @@context
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

    def get_reaction(pattern)

      if pattern.satisfied?(children)
        result = if children.key?("#") && children["#"].template
                   Reaction.new(children["#"].template)
                 elsif template
                   Reaction.new(template)
                 elsif children.key?("^") && children["^"].template
                   Reaction.new(children["^"].template)
                 elsif children.key?(AIML::RETURN)
                   t = children[AIML::RETURN].template
                   Reaction.new(t) if t
                 end
        return result
      end

      if pattern.qualified?(children)
        result = if reaction = children[pattern.key].get_reaction(pattern.suffix)
                   reaction
                 elsif children.key?("#") && children["#"].template
                   Reaction.new(children["#"].template)
                 elsif children.key?("^") && children["^"].template
                   Reaction.new(children["^"].template)
                 end
        return result if result
      end

      if children.key?("$#{pattern.key}")
        reaction = children["$#{pattern.key}"].get_reaction(pattern.suffix)
        if reaction
          reaction.increment
          return reaction
        end
      end

      if children.key?("#")
        reaction = match_wildcard(pattern, children["#"])
        return reaction if reaction
      end

      if children.key?("_")
        reaction = match_wildcard(pattern, children["_"], greedy: true, min_match: 1)
        return reaction if reaction
      end

      if children.key?(pattern.key)
        if reaction = children[pattern.key].get_reaction(pattern.suffix)
          reaction.increment
          return reaction
        end
      end

      if match_variables?
        reaction = match_variable(pattern)
        return reaction if reaction
      end

      if match_sets?
        reaction = match_set(pattern)
        return reaction if reaction
      end

      if match_properties?
        reaction = match_property(pattern)
        return reaction if reaction
      end

      if children.key?("^")
        reaction = match_wildcard(pattern, children["^"], greedy: true)
        return reaction if reaction
      end

      if children.key?("*")
        reaction = match_wildcard(pattern, children["*"], min_match: 1)
        return reaction if reaction
      end

      if pattern.start_context_segment?
        reaction = get_reaction(pattern.next_segment)
        return reaction if reaction
      end

      if children.key?(AIML::RETURN)
        t = children[AIML::RETURN].template
        return Reaction.new(t) if t
      end

      nil
    end

    private

    def sets
      @sets ||= children.keys.select { |key| key.is_a? AIML::Tags::MatchSet }
    end

    def match_sets?
      sets.any?
    end

    def match_wildcard(pattern, graph, greedy: false, min_match: 0)
      return unless min_match <= pattern.current_segment_size
      result = nil
      if pattern.start_context_segment?
        result = graph.get_reaction(pattern)
      end
      if result.nil? and pattern.current_segment_size >= min_match
        result = search_suffixes(pattern, graph, greedy: greedy, min_match: min_match)
      end
      if result.nil? and graph.template and pattern.current_segment_size >= min_match
        result = Reaction.new(graph.template).tap{ |r| r.add_match_group(pattern.current_segment_type, pattern.current_segment) }
      end
      result
    end

    def search_suffixes(pattern, graph, greedy: false, min_match: 0)
      index = min_match
      memo = pattern.safe_suffix(index)
      result = nil
      while memo
        if reaction = graph.get_reaction(memo)
          reaction.add_match_group(pattern.current_segment_type, pattern.path[0...index])
          result = reaction
        end
        return result unless memo.key_matchable? && ( result.nil? || greedy )
        index += 1
        memo = memo.safe_suffix
      end
      result
    end

    def match_set(pattern)
      result = nil
      current_depth = 0
      sets.each do |set|
        next unless match = set.match(pattern)
        depth = match.depth
        next unless depth > current_depth
        reaction = children[set].get_reaction(pattern.suffix(depth))
        if reaction
          reaction.add_match_group(pattern.current_segment_type, match.template)
          result = reaction
          current_depth = depth
        end
      end
      result
    end

    def properties
      @properties ||= children.keys.select { |key| key.is_a? AIML::Tags::MatchProperty }
    end

    def match_properties?
      properties.any?
    end

    def match_property(pattern)
      properties.each do |property|
        match = property.match(pattern, children[property], context)
        return match if match
      end
      nil
    end

    def variables
      @variables ||= children.keys.select { |key| key.is_a? AIML::Tags::MatchVariable }
    end

    def match_variables?
      variables.any?
    end

    def match_variable(pattern)
      variables.each do |variable|
        match = variable.match(pattern, children[variable], context)
        return match if match
      end
      nil
    end

  end

end

