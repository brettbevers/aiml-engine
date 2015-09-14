module AimlEngine

  class Reaction

    attr_accessor :template, :star, :that_star, :topic_star

    def initialize(template)
      @template   = template
      @star       = []
      @that_star  = []
      @topic_star = []
    end

    def add_match_group(segment, match_group)
      case segment
        when :stimulus
          star.unshift match_group
        when :that
          that_star.unshift match_group
        when :topic
          topic_star.unshift match_group
      end
    end

  end

end