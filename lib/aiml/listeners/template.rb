module AIML::Listeners
  class Template < Base

    TAGS = [AIML::Tags::Template, AIML::Tags::Star, AIML::Tags::Random,
            AIML::Tags::Question, AIML::Tags::Condition, AIML::Tags::Set,
            AIML::Tags::Think, AIML::Tags::Srai, AIML::Tags::Command]

    def self.tag_names
      TAGS.map { |klass| klass.tag_names }.flatten
    end

    attr_reader :learner

    def initialize(context, learner)
      @learner = learner
      super(context)
    end

    def start_element(uri, localname, qname, attributes)
      if AIML::Tags::Template.tag_names.include?(localname)
        expect_current_tag_is AIML::Tags::Category
        template = AIML::Tags::Template.new
        current_tag.template = template
        push_tag template
        return
      end

      return unless open_template?

      case localname

        when *AIML::Tags::Star.tag_names
          add_tag AIML::Tags::Star.new(localname, attributes)

        when *AIML::Tags::Random.tag_names
          attributes['name'] ||= localname
          add_tag AIML::Tags::Random.new(attributes)

        when *AIML::Tags::Question.tag_names
          add_tag AIML::Tags::Question.new

        when *AIML::Tags::Condition.tag_names
          add_tag AIML::Tags::Condition.new(attributes)

        when *AIML::Tags::Set.tag_names
          add_tag AIML::Tags::Set.new(localname, attributes)

        when *AIML::Tags::Think.tag_names
          add_tag AIML::Tags::Think.new

        when *AIML::Tags::Srai.tag_names
          object = localname == 'sr' ? AIML::Tags::Star.new('star') : nil
          add_tag AIML::Tags::Srai.new(object)

        when *AIML::Tags::Command.tag_names
          add_tag AIML::Tags::Command.new

        when *AIML::Tags::ListItem.tag_names
          if current_tag_is? AIML::Tags::Condition
            attributes['name'] ||= current_tag.property
            attributes['value'] ||= current_tag.value
            add_tag AIML::Tags::ListItem.new(attributes)
          elsif current_tag_is? AIML::Tags::Random
            add_tag AIML::Tags::ListItem.new(attributes)
          end

        when *AIML::Tags::Learn.tag_names
          add_tag AIML::Tags::Learn.new(learner)

        when *AIML::Tags::Eval.tag_names
          expect_open AIML::Tags::Learn
          add_tag AIML::Tags::Eval.new

      end
    end

    def characters(text)
      return unless open_template? && !current_tag_is?(AIML::Tags::Category)

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
      open_template? and super
    end

  end
end