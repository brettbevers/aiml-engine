module AIML

  class MapElement

    attr_reader :map_name, :key, :body, :path

    def initialize(map_name, key, value)
      @map_name = AIML::Tags::Pattern.process(map_name)
      @key      = AIML::Tags::Pattern.process(key)
      @body     = AIML::Tags::Pattern.process(value)
      @path     = @map_name + @key
    end

    def template
      AIML::Tags::Template.new.tap do |template|
        star_index = 1
        body.each do |token|
          case token
            when /^(\*|_|#|\^)$/
              template.add AIML::Tags::Star.new('star', 'index' => star_index)
              star_index += 1
            else
              template.add(token)
          end
        end
      end
    end

  end

end