require_relative 'base'

module AIML::Listeners
  class ListItem < Base

    def start_element(uri, localname, qname, attributes)
      case localname

        when *AIML::Tags::ListItem::TAG_NAMES
          add_tag AIML::Tags::ListItem(attributes)

      end
    end

    def end_element(uri, localname, qname)
      case localname

        when *AIML::Tags::ListItem::TAG_NAMES
          expect_current_tag AIML::Tags::ListItem
          pop_tag

      end
    end

  end
end

