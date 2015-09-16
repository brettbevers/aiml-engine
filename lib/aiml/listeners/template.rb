module AIML::Listeners
  class Template < Base

    TAGS = [AIML::Tags::Template, AIML::Tags::Star, AIML::Tags::Random,
            AIML::Tags::Question, AIML::Tags::Condition, AIML::Tags::SetTag,
            AIML::Tags::Think, AIML::Tags::Srai, AIML::Tags::Command]

    TAG_NAMES = TAGS.map { |klass| klass::TAG_NAMES }.flatten

    def start_element(uri, localname, qname, attributes)
      if AIML::Tags::Template::TAG_NAMES.include?(localname)
        expect_current_tag_is AIML::Tags::Category
        template = AIML::Tags::Template.new
        current_tag.template = template
        push_tag template
        return
      end

      return unless open_template?

      case localname

        when *AIML::Tags::Star::TAG_NAMES
          add_tag AIML::Tags::Star.new(localname, attributes)

        when *AIML::Tags::Random::TAG_NAMES
          attributes['name'] ||= localname
          add_tag AIML::Tags::Random.new(attributes)

        when *AIML::Tags::Question::TAG_NAMES
          add_tag AIML::Tags::Question.new

        when *AIML::Tags::Condition::TAG_NAMES
          add_tag AIML::Tags::Condition.new(attributes)

        when *AIML::Tags::SetTag::TAG_NAMES
          add_tag AIML::Tags::SetTag.new(localname, attributes)

        when *AIML::Tags::Think::TAG_NAMES
          add_tag AIML::Tags::Think.new

        when *AIML::Tags::Srai::TAG_NAMES
          object = localname == 'sr' ? AIML::Tags::Star.new('star') : nil
          add_tag AIML::Tags::Srai.new(object)

        when *AIML::Tags::Command::TAG_NAMES
          add_tag AIML::Tags::Command.new

      end
    end

    def characters(text)
      case current_tag

        when AIML::Tags::Condition
          return if /^\s*$/ === text
          li = AIML::Tags::ListItem.new('name' => current_tag.property, 'value' => current_tag.value)
          li.add(text)
          add_to_tag li

        when AIML::Tags::Random
          return if /^\s*$/ === text
          li = AIML::Tags::ListItem.new
          li.add(text)
          add_to_tag li

        else
          super

      end
    end

    def end_element(uri, localname, qname)
      return unless open_template?
      expect_current_tag_is localname
      pop_tag
    end

  end
end