module AIML::Tags
  class Learn < Base

    def self.tag_names
      %w{ learn }
    end

    attr_reader :learner, :body
    alias_method :categories, :body

    def initialize(learner)
      @learner = learner
      @body = []
    end

    def add(object)
      if object.is_a?(AIML::Tags::Category)
        body.push object
      end
    end

    def to_s(context)
      body.each do |category|
        category = Marshal::load(Marshal.dump(category))
        %w{template that topic pattern}.each do |attr|
          component = category.send(attr)
          component.body = render(component.body, context)
          learner.learn(category)
        end
      end
      return ''
    end

    def render(body, context, eval=false)
      body.map! { |token|
        if token.is_a? AIML::Tags::Eval
          render(token.body, context, true)
          token.body
        elsif eval
          token.to_s(context)
        else
          if token.respond_to?(:body)
            render(token.body, context, eval)
          end
          token
        end
      }.flatten
    end

    def inspect
      "Learn -> #{body.map(&:inspect).join(' ')}"
    end

  end
end
