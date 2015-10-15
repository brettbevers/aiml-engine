module AIML

  class SetElement

    attr_reader :set_name, :body, :path

    def initialize(set_name, text)
      @set_name = AIML::Tags::Pattern.process(set_name)
      @body = AIML::Tags::Pattern.process(text)
      @path = @set_name + @body
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