require 'rexml/sax2listener'

module AIML::Listeners
  class Base

    include REXML::SAX2Listener

    attr_reader :context

    def initialize(context)
      @context = context
    end

    def characters(text)
      add_to_tag text
    end

    def current_tag
      context.tag
    end

    def current_tag_names
      current_tag.class::TAG_NAMES
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

    def current_tag_is?(*klasses_and_tag_names)
      klasses_and_tag_names.reduce(false) { |memo, klass_or_tag_name|
        memo or case klass_or_tag_name
                  when String
                    current_tag.class::TAG_NAMES.reduce(false){ |memo,name| memo || name === klass_or_tag_name }
                  when Class
                    current_tag.is_a?(klass_or_tag_name)
                end
      }
    end

    def expect_current_tag_is(*klasses_and_tag_names)
      unless current_tag_is?(*klasses_and_tag_names)
        raise AIML::TagMismatch, "expected #{current_tag.inspect} to be #{klasses_and_tag_names}"
      end
    end
  end
end
