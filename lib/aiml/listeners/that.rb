module AIML::Listeners
  class That < Base

    def start_element(uri, localname, qname, attributes)
      if current_tag.is_a? AIML::Tags::Category
        that = AIML::Tags::That.new
        current_tag.that = that
        push_tag that
      else
        add_tag AIML::Tags::ReadOnlyTag.new(localname, attributes)
      end
    end

    def end_element(uri, localname, qname)
      expect_current_tag_is AIML::Tags::That, AIML::Tags::ReadOnlyTag
      pop_tag
    end

  end
end