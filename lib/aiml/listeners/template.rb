module AIML::Listeners
  class Template < Base

    def start_element(uri, local_name, qname, attributes)
      if AIML::Tags::Template.tag_names.include?(local_name)
        expect_current_tag_is AIML::Tags::Category
        template = AIML::Tags::Template.new
        current_tag.template = template
        push_tag template
        return
      end

      return unless open_template? && ( !open_pattern? || open_eval? )

      case local_name

        when *AIML::Tags::Star.tag_names
          add_to_tag AIML::Tags::Star.new(local_name, attributes)

        when *AIML::Tags::Random.tag_names
          attributes['name'] ||= local_name
          add_tag AIML::Tags::Random.new

        when *AIML::Tags::Condition.tag_names
          add_tag AIML::Tags::Condition.new(local_name, attributes)

        when *AIML::Tags::Set.tag_names
          add_tag AIML::Tags::Set.new(local_name, attributes)

        when *AIML::Tags::Think.tag_names
          add_tag AIML::Tags::Think.new

        when *AIML::Tags::Srai.tag_names
          object = local_name == 'sr' ? AIML::Tags::Star.new('star') : nil
          add_tag AIML::Tags::Srai.new(object)

        when *AIML::Tags::ListItem.tag_names
          if current_tag_is? AIML::Tags::Condition
            attributes['name'] ||= current_tag.name if current_tag.name?
            attributes['value'] ||= current_tag.value if current_tag.value?
            add_tag AIML::Tags::ListItem.new(local_name, attributes)
          elsif current_tag_is? AIML::Tags::Random
            add_tag AIML::Tags::ListItem.new(local_name, attributes)
          end

        when *AIML::Tags::Loop.tag_names
          expect_current_tag_is AIML::Tags::ListItem
          parent_tag = context.open_tags[-2]
          expect_tag_is parent_tag, AIML::Tags::Condition
          add_to_tag AIML::Tags::Loop.new(parent_tag)

        when *AIML::Tags::Learn.tag_names
          add_tag AIML::Tags::Learn.new(learner)

        when *AIML::Tags::Get.tag_names
          add_to_tag AIML::Tags::Get.new(local_name, attributes)

        when *AIML::Tags::ReadProperty.tag_names
          add_to_tag AIML::Tags::ReadProperty.new(local_name, attributes)

        when *AIML::Tags::Map.tag_names
          add_tag AIML::Tags::Map.new(learner, attributes)

        when *AIML::Tags::Normalize.tag_names
          add_tag AIML::Tags::Normalize.new(learner, attributes)

        when *AIML::Tags::Denormalize.tag_names
          add_tag AIML::Tags::Denormalize.new(learner, attributes)

        when *AIML::Tags::Date.tag_names
          add_to_tag AIML::Tags::Date.new(local_name, attributes)

        when *AIML::Tags::Interval.tag_names
          add_tag AIML::Tags::Interval.new(local_name, attributes)

        when *AIML::Tags::UpperCase.tag_names
          add_tag AIML::Tags::UpperCase.new

        when *AIML::Tags::LowerCase.tag_names
          add_tag AIML::Tags::LowerCase.new

        when *AIML::Tags::Formal.tag_names
          add_tag AIML::Tags::Formal.new

        when *AIML::Tags::Sentence.tag_names
          add_tag AIML::Tags::Sentence.new

        when *AIML::Tags::Explode.tag_names
          add_tag AIML::Tags::Explode.new
      end
    end

    def characters(text)
      return unless open_template? && !current_tag_is?(AIML::Tags::Category)
      text = text.gsub(/[\n\r]+/,'').gsub(/\s+/,' ')
      super
    end

    def end_element(uri, local_name, qname)
      open_template? and super
    end

  end
end