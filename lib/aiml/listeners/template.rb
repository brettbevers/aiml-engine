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

      return unless open_template?

      case local_name

        when *AIML::Tags::Star.tag_names
          add_tag AIML::Tags::Star.new(local_name, attributes)

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
          add_tag AIML::Tags::Loop.new(parent_tag)

        when *AIML::Tags::Learn.tag_names
          add_tag AIML::Tags::Learn.new(learner)

        when *AIML::Tags::Eval.tag_names
          expect_open AIML::Tags::Learn
          add_tag AIML::Tags::Eval.new

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
      end
    end

    def characters(text)
      return unless open_template? && !current_tag_is?(AIML::Tags::Category)
      text = text.gsub(/[\s\n\r]+/,' ')

      case current_tag

        when AIML::Tags::Condition
          return if /\A\s*\z/ === text
          attrs = {}
          attrs['name'] ||= current_tag.name if current_tag.name?
          attrs['value'] ||= current_tag.value if current_tag.value?
          li = AIML::Tags::ListItem.new(attrs)
          li.add(text)
          add_to_tag li

        when AIML::Tags::Random
          return if /\A\s*\z/ === text
          li = AIML::Tags::ListItem.new
          li.add(text)
          add_to_tag li

        else
          super

      end
    end

    def end_element(uri, local_name, qname)
      open_template? and super
    end

  end
end