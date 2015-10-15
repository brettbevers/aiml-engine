require_relative 'base'

module AIML::Listeners
  class Pattern < Base

    attr_reader :learner

    def initialize(context, learner)
      @learner = learner
      super(context)
    end

    def start_element(uri, local_name, qname, attributes)
      if AIML::Tags::Pattern.tag_names.include?(local_name)
        expect_current_tag_is AIML::Tags::Category
        pattern = AIML::Tags::Pattern.new
        current_tag.pattern = pattern
        push_tag pattern
      end

      return unless open_pattern?

      case local_name
        when *AIML::Tags::MatchSet.tag_names
          add_tag AIML::Tags::MatchSet.new(learner)

        when *AIML::Tags::MatchProperty.tag_names
          add_tag AIML::Tags::MatchProperty.new(local_name, attributes)

        when *AIML::Tags::MatchVariable.tag_names
          add_tag AIML::Tags::MatchVariable.new(local_name, attributes)
      end

    end

    def characters(text)
      open_pattern? && !open_template? && !open_that? and super
    end

    def end_element(uri, local_name, qname)
      open_pattern? && !open_template? && !open_that? and super
    end

  end
end