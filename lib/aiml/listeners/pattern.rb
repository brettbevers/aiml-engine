require_relative 'base'

module AIML::Listeners
  class Pattern < Base

    def start_element(uri, localname, qname, attributes)
      if AIML::Tags::Pattern.tag_names.include?(localname)
        expect_current_tag_is AIML::Tags::Category
        pattern = AIML::Tags::Pattern.new
        current_tag.pattern = pattern
        push_tag pattern
      end
    end

    def characters(text)
      open_pattern? && !open_template? && !open_that? and super
    end

    def end_element(uri, localname, qname)
      open_pattern? && !open_template? && !open_that? and super
    end

  end
end