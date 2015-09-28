module AIML::Tags
  class Learn < Base

    attr_reader :learner
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
        %w{template that pattern}.each do |attr|
          next unless component = category.send(attr)
          render!(component.body, context)
        end
        category.pattern.reprocess_stimulus
        learner.learn(category)
      end
      return ''
    end

    def render!(body, context, eval=false)
      body.map! { |token|
        if token.is_a? AIML::Tags::Eval
          render!(token.body, context, true)
          token.body
        elsif eval
          token.to_s(context)
        else
          if token.respond_to?(:body)
            render!(token.body, context, eval)
          end
          token
        end
      }
      body.flatten!
    end

  end
end
