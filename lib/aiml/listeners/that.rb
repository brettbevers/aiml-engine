module AIML::Listeners
  class That < Base

    def start_element(uri, local_name, qname, attributes)
      if AIML::Tags::That.tag_names.include?(local_name)
        if current_tag_is? AIML::Tags::Category
          that = AIML::Tags::That.new
          current_tag.that = that
          push_tag that
        elsif open_template?
          add_tag AIML::Tags::That.new(attributes)
        end
      end
    end

    def characters(text)
      open_that? && !open_template? && !open_pattern? and super
    end

    def end_element(uri, local_name, qname)
      open_that? && !open_template? && !open_pattern? and super
    end

  end
end