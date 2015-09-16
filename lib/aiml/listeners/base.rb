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

    def expect_current_tag(*klasses)
      unless klasses.reduce(false) { |memo, klass| memo || current_tag.is_a?(klass) }
        raise AIML::TagMismatch, "expected #{current_tag.inspect} to be #{klass.name}"
      end
    end
  end
end
