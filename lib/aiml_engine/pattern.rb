module AimlEngine
  class Pattern

    SEGMENTER = /^\s*(.*?)?(\s*(?<!#{THAT})#{THAT}\s+(.*?))?(\s*(?<!#{TOPIC})#{TOPIC}\s+(.*?))?\s*$/

    attr_reader :raw_stimulus, :context

    def initialize(raw_stimulus: nil, context: nil, path: nil, stimulus: nil)
      @raw_stimulus = raw_stimulus
      @context = context
      @path = path
      @stimulus = stimulus
    end

    def path
      @path ||= [
          stimulus,
          THAT, that,
          TOPIC, topic
      ].flatten.compact
    end

    def stimulus
      @stimulus ||= process_string(raw_stimulus)
    end

    def satisfied?(children)
      path.empty? ||
          (start_that_segment? && context_irrelevant?(children)) ||
          (start_topic_segment? && topic_irrelevant?(children))
    end

    def key
      path[0]
    end

    def start_context_segment?
      start_that_segment? || start_topic_segment?
    end

    def start_that_segment?
      key == THAT
    end

    def start_topic_segment?
      key == TOPIC
    end

    def null_key?
      [DEFAULT, UNDEF].include?(key)
    end

    def key_matchable?
      !null_key? && !start_context_segment?
    end

    def context_irrelevant?(children)
      !children.key?(THAT) && !children.key?(TOPIC)
    end

    def topic_irrelevant?(children)
      !children.key?(TOPIC)
    end

    def suffix
      @suffix ||= begin
        p = path[1..-1]     || []
        s = stimulus[1..-1] || []
        Pattern.new(path: p, stimulus: s, context: context)
      end
    end

    def suffixes
      return @result if @result
      @result = {}
      (1...path.size).each do |index|
        p = path[index..-1]     || []
        s = stimulus[index..-1] || []
        @result[index] = Pattern.new(path: p, stimulus: s, context: context)
      end
      @result
    end

    def that
      @that ||= process_string(context.that)
    end

    def topic
      @topic ||= process_string(context.topic)
    end

    def topic_segment
      @topic_segment ||= begin
        p = [TOPIC, topic].flatten
        Pattern.new( path: p, stimulus: [], context: context)
      end
    end

    def default_topic?
      topic == DEFAULT
    end

    def process_string(str)
      return unless str
      str.strip.upcase.split(/\s+/)
    end

  end
end