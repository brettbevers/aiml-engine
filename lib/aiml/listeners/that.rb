module AIML::Listeners
  class That < Base

    def start_element(uri, localname, qname, attributes)
      if AIML::Tags::That.tag_names.include?(localname)
        if current_tag_is? AIML::Tags::Category
          that = AIML::Tags::That.new
          current_tag.that = that
          push_tag that
        elsif open_template?
          add_tag AIML::Tags::ReadOnly.new(localname, attributes)
        end
      end
    end

    def characters(text)
      open_that? && !open_template? && !open_pattern? and super
    end

    def end_element(uri, localname, qname)
      open_that? && !open_template? && !open_pattern? and super
    end

  end
end