require 'rexml/sax2listener'

module AIML::Listeners
  class Base

    include REXML::SAX2Listener

    attr_reader :context, :learner

    def initialize(context, learner)
      @context = context
      @learner = learner
    end

    def characters(text)
      # if /\A(\S*)\s*[\n\r]\s*\z/ === text
      #   return unless $1
      #   text = $1
      # end
      add_to_tag text
    end

    def end_element(uri, local_name, qname)
      pop_tag if current_tag_is? local_name
    end

    def current_tag
      context.tag
    end

    def current_tag_names
      current_tag.class.tag_names
    end

    def add_to_tag(value)
      context.add_to_tag(value)
    end

    def add_tag(tag)
      context.add_tag(tag)
    end

    def push_tag(tag)
      context.push_tag(tag)
    end

    def pop_tag
      context.pop_tag
    end

    def open_template?
      context.open_template?
    end

    def open_pattern?
      context.open_pattern?
    end

    def open_that?
      context.open_that?
    end

    def current_tag_is?(*klasses_and_tag_names)
      context.tag_is?(current_tag, *klasses_and_tag_names)
    end

    def expect_current_tag_is(*klasses_and_tag_names)
      context.expect_tag_is(current_tag, *klasses_and_tag_names)
    end

    def expect_current_tag_is_not(*klasses_and_tag_names)
      context.expect_tag_is_not(current_tag, *klasses_and_tag_names)
    end

    def expect_tag_is(tag, *klasses_and_tag_names)
      context.expect_tag_is(tag, *klasses_and_tag_names)
    end

    def expect_tag_is_not(tag, *klasses_and_tag_names)
      context.expect_tag_is_not(tag, *klasses_and_tag_names)
    end

    def expect_open(*klasses_and_tag_names)
      context.expect_open(*klasses_and_tag_names)
    end

    def expect_not_open(*klasses_and_tag_names)
      context.expect_not_open(*klasses_and_tag_names)
    end
  end
end
