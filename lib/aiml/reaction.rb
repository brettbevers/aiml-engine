module AIML

  class Reaction

    attr_accessor :template, :star, :that_star, :topic_star, :depth

    def initialize(template)
      @template   = template
      @star       = []
      @that_star  = []
      @topic_star = []
      @depth = 0
    end

    def add_match_group(segment, match_group)
      return if match_group.empty?
      @depth += match_group.size
      case segment
        when :stimulus
          star.unshift match_group
        when :that
          that_star.unshift match_group
        when :topic
          topic_star.unshift match_group
      end
    end

    def increment(interval=1)
      @depth += interval
    end

    def decrement(interval=1)
      @depth -= interval
    end

  end

end