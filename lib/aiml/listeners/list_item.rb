require_relative 'base'

module AIML::Listeners
  class ListItem < Base

    def start_element(uri, localname, qname, attributes)
      case current_tag

        when AIML::Tags::Condition
          attributes['name']  ||= current_tag.property
          attributes['value'] ||= current_tag.value
          add_tag AIML::Tags::ListItem.new(attributes)

        when AIML::Tags::Random
          add_tag AIML::Tags::ListItem.new(attributes)

      end
    end

    def end_element(uri, localname, qname)
      case current_tag
        when AIML::Tags::ListItem
          pop_tag
      end
    end

  end
end

