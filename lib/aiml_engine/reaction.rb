module AimlEngine

  class Reaction

    attr_reader :template, :match_group

    def initialize(template, match_group=[])
      @template = template
      @match_group = match_group
    end

    def render_template
      template.map { |token|
        case token
          when Star
            match_group
          else
            token
        end
      }.flatten
    end

  end

end