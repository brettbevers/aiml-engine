require_relative 'base'

module AIML::Listeners
  class Pattern < Base

    def start_element(uri, localname, qname, attributes)
      expect_current_tag AIML::Tags::Category
      pattern = AIML::Tags::Pattern.new
      current_tag.pattern = pattern
      push_tag pattern
    end

    def end_element(uri, localname, qname)
      expect_current_tag AIML::Tags::Pattern
      pop_tag
    end

  end
end