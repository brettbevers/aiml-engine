require 'rexml/parsers/sax2parser'
require_relative 'aiml_elements'
require_relative 'listeners/pattern'
require_relative 'listeners/that'
require_relative 'listeners/template'
require_relative 'listeners/list_item'

module AIML
  class Parser

    attr_reader :context, :learner, :files

    def initialize(learner, context=Context.new)
      @learner = learner
      @context = context
      @files = []
    end

    def parse(aiml)
      @parser = REXML::Parsers::SAX2Parser.new(aiml)

      ### topic
      @parser.listen(%w{ topic }) { |uri, local_name, qname, attributes|
        raise "Cannot overwrite topic" if context.topic
        context.topic = attributes['name']
      }

      @parser.listen(:end_element, %w{ topic }) {
        context.topic = nil
      }
      ### end topic

      ### category
      @parser.listen(AIML::Tags::Category.tag_names) { |uri, local_name, qname, attributes|
        if context.current_tag_is? AIML::Tags::Learn
          context.add_tag AIML::Tags::Category.new(attributes['topic'])
        else
          context.expect_not_open AIML::Tags::Category, AIML::Tags::Pattern, AIML::Tags::Template, AIML::Tags::That
          context.push_tag AIML::Tags::Category.new(attributes['topic'] || context.topic)
        end
      }

      @parser.listen(:end_element, AIML::Tags::Category.tag_names) {
        context.expect_current_tag_is AIML::Tags::Category
        unless context.open? AIML::Tags::Learn
          learner.learn(context.pop_tag)
        end
      }
      ### end category

      ### learn / eval
      @parser.listen(AIML::Tags::Learn.tag_names) { |uri, local_name, qname, attributes|
        if attributes['filename']
          AimlFinder.find(attributes['filename']).each do |filename|
            text = File.open(filename).read
            parse(text)
          end
        end
      }
      ### end learn / eval

      ### gender / person / person2
      tag_names = AIML::Tags::Gender.tag_names + AIML::Tags::Person.tag_names + AIML::Tags::Person2.tag_names
      @parser.listen(tag_names) { |uri, local_name, qname, attributes|
        break unless context.open? AIML::Tags::Category

        case local_name
          when *AIML::Tags::Gender.tag_names
            context.add_tag AIML::Tags::Gender.new
          when *AIML::Tags::Person.tag_names
            context.add_tag AIML::Tags::Person.new
          when *AIML::Tags::Person2.tag_names
            context.add_tag AIML::Tags::Person2.new
        end
      }

      @parser.listen(:end_element, tag_names) {
        context.expect_current_tag_is *tag_names
        if context.tag.body.empty?
          context.add_to_tag(AIML::Tags::Star.new('star'))
        end
      }
      ### end gender / person / person2

      ### self-terminating tags
      @parser.listen(AIML::Tags::ReadOnly.tag_names - %w{ that }) { |uri, local_name, qname, attributes|
        context.add_to_tag AIML::Tags::ReadOnly.new(local_name, attributes)
      }

      @parser.listen(%w{ br }) {
        context.add_to_tag "\n"
      }

      @parser.listen(%w{ input }) { |uri, local_name, qname, attributes|
        context.add_to_tag AIML::Tags::Input.new(attributes)
      }

      @parser.listen(%w{ date }) {
        context.add_to_tag(AIML::Tags::Sys_Date.new)
      }

      @parser.listen(%w{ size }) {
        context.add_to_tag(AIML::Tags::Size.new)
      }
      ### end self-terminating tags

      ### string manipulation
      @parser.listen(:characters, AIML::Tags::UpperCase.tag_names) { |text|
        context.add_to_tag(AIML::Tags::UpperCase.new(text))
      }

      @parser.listen(:characters, AIML::Tags::LowerCase.tag_names) { |text|
        context.add_to_tag(AIML::Tags::LowerCase.new(text))
      }

      @parser.listen(:characters, AIML::Tags::Formal.tag_names) { |text|
        context.add_to_tag(AIML::Tags::Formal.new(text))
      }

      @parser.listen(:characters, AIML::Tags::Sentence.tag_names) { |text|
        context.add_to_tag(AIML::Tags::Sentence.new(text))
      }
      ### end string manipulation

      ### version
      @parser.listen(%w{ version }) {
        context.add_to_tag "AIML 1.0"
      }
      ### end version

      ### pattern / that / template
      @parser.listen(Listeners::Pattern.new(context))
      @parser.listen(Listeners::That.new(context))
      @parser.listen(Listeners::Template.new(context, learner))
      ### end pattern / that / template

      @parser.parse
    end


    class Context

      attr_reader :open_tags
      attr_accessor :topic

      def initialize(open_tags=nil)
        @open_tags = open_tags || []
      end

      def push_tag(value)
        open_tags.push(value)
      end

      def pop_tag
        open_tags.pop
      end

      def tag
        open_tags[-1]
      end

      def add_tag(tag)
        add_to_tag tag
        push_tag tag
      end

      def add_to_tag(value)
        if tag.nil? || tag.is_a?(AIML::Tags::Category)
          raise MissingParentTag, "No parent tag to accept #{value.inspect}"
        end
        tag.add(value)
      end

      def open_tags?
        open_tags.any?
      end

      def open_template?
        open? AIML::Tags::Template
      end

      def open_pattern?
        open? AIML::Tags::Pattern
      end

      def open_that?
        open? AIML::Tags::That
      end

      def open?(*klasses_or_tag_names)
        open_tags.reduce(false) { |memo, tag|
          memo || tag_is?(tag, *klasses_or_tag_names)
        }
      end

      def expect_open(*klasses_and_tag_names)
        unless open? *klasses_and_tag_names
          raise AIML::TagError, "expected some #{klasses_and_tag_names} to be open.\nOpen tags:\n#{open_tags.map(&:inspect).join("\n")}"
        end
      end

      def expect_not_open(*klasses_and_tag_names)
        if open? *klasses_and_tag_names
          raise AIML::TagError, "did not expect any #{klasses_and_tag_names} to be open.\nOpen tags:\n#{open_tags.map(&:inspect).join("\n")}"
        end
      end

      def current_tag_is?(*klasses_and_tag_names)
        tag_is? tag, *klasses_and_tag_names
      end

      def tag_is?(_tag, *klasses_and_tag_names)
        klasses_and_tag_names.reduce(false) do |memo, klass_or_tag_name|
          memo or case klass_or_tag_name
                    when String
                      _tag.class.tag_names.reduce(false) { |memo, name| memo || name === klass_or_tag_name }
                    when Class
                      _tag.is_a?(klass_or_tag_name)
                  end
        end
      end

      def expect_tag_is(_tag, *klasses_and_tag_names)
        unless tag_is? _tag, *klasses_and_tag_names
          raise AIML::TagMismatch, "expected #{_tag.inspect} to be #{klasses_and_tag_names}.\nOpen tags:\n#{open_tags.map(&:inspect).join("\n")}"
        end
      end

      def expect_tag_is_not(_tag, *klasses_and_tag_names)
        if tag_is? _tag, *klasses_and_tag_names
          raise AIML::TagMismatch, "did not expect #{_tag.inspect} to be #{klasses_and_tag_names}.\nOpen tags:\n#{open_tags.map(&:inspect).join("\n")}"
        end
      end

      def expect_current_tag_is(*klasses_and_tag_names)
        expect_tag_is tag, *klasses_and_tag_names
      end
    end

  end #Aiml@parser
end
