require 'rexml/parsers/sax2parser'
require_relative 'aiml_elements'
require_relative 'listeners/pattern'
require_relative 'listeners/that'
require_relative 'listeners/template'
require_relative 'listeners/list_item'

module AIML
  class Parser

    attr_reader :context, :learner, :files

    def initialize(learner, context=nil)
      @learner = learner
      @context = context || Context.new
      @files = []
    end

    def parse(aiml)
      @parser = REXML::Parsers::SAX2Parser.new(aiml)

      ### learn
      @parser.listen(%w{ learn }){ |uri, local_name, qname, attributes|
        AimlFinder.find(attributes['filename'] || attributes['path']).each do |filename|
          text = File.open(filename).read
          parse(text)
        end
      }
      ### end learn

      ### topic
      @parser.listen(%w{ topic }) { |uri, local_name, qname, attributes|
        context.topic = attributes['name']
      }

      @parser.listen(:end_element, %w{ topic }) {
        context.topic = nil
      }
      ### end topic

      ### category
      @parser.listen(AIML::Tags::Category::TAG_NAMES) { |uri, local_name, qname, attributes|
        context.push_tag AIML::Tags::Category.new(attributes['topic'] || context.topic)
      }

      @parser.listen(:end_element, AIML::Tags::Category::TAG_NAMES) {
        @learner.learn(context.pop_tag)
      }
      ### end category

      ### pattern / that / template
      @parser.listen(AIML::Tags::Pattern::TAG_NAMES, Listeners::Pattern.new(context))
      @parser.listen(AIML::Tags::That::TAG_NAMES,    Listeners::That.new(context))
      @parser.listen(Listeners::Template::TAG_NAMES, Listeners::Template.new(context))
      ### end pattern / that / template

      ### list item
      @parser.listen(AIML::Tags::ListItem::TAG_NAMES, Listeners::ListItem.new(context))
      ### end list item

      ### gender / person / person2
      tag_names = AIML::Tags::Gender::TAG_NAMES + AIML::Tags::Person::TAG_NAMES + AIML::Tags::Person2::TAG_NAMES
      @parser.listen(tag_names) { |uri, local_name, qname, attributes|

        case local_name
          when *AIML::Tags::Gender::TAG_NAMES
            context.add_tag AIML::Tags::Gender.new
          when *AIML::Tags::Person::TAG_NAMES
            context.add_tag AIML::Tags::Person.new
          when *AIML::Tags::Person2::TAG_NAMES
            context.add_tag AIML::Tags::Person2.new
        end
      }

      @parser.listen(:characters, tag_names) { |text|
        context.add_to_tag(text)
      }

      @parser.listen(:end_element, tag_names) {
        context.pop_tag
      }
      ### end gender / person / person2

      ### self-terminating tags
      @parser.listen(AIML::Tags::ReadOnlyTag::TAG_NAMES) { |uri, local_name, qname, attributes|
        context.add_to_tag AIML::Tags::ReadOnlyTag.new(local_name, attributes)
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
      @parser.listen(:characters, %w{ uppercase }) { |text|
        context.add_to_tag(text.upcase.gsub(/\s+/, ' '))
      }

      @parser.listen(:characters, %w{ lowercase }) { |text|
        context.add_to_tag(text.downcase.gsub(/\s+/, ' '))
      }

      @parser.listen(:characters, %w{ formal }) { |text|
        text.gsub!(/(\w+)/) { $1.capitalize }
        context.add_to_tag(text.gsub(/\s+/, ' '))
      }

      @parser.listen(:characters, %w{ sentence }) { |text|
        context.add_to_tag(text.capitalize.gsub(/\s+/, ' '))
      }
      ### end string manipulation


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
          raise MissingParentTag, "No parent tag to add #{value.inspect} to"
        end
        tag.add(value)
      end

      def open_tags?
        open_tags.any?
      end

      def open_template?
        open_tags.reduce(false) { |memo, tag| memo || tag.is_a?(AIML::Tags::Template) }
      end
    end

  end #Aiml@parser
end
