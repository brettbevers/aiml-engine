module AimlEngine
  class Pattern

    SEGMENTER = /^\s*(.*?)?(\s*(?<!#{THAT})#{THAT}\s+(.*?))?(\s*(?<!#{TOPIC})#{TOPIC}\s+(.*?))?\s*$/

    attr_accessor :raw_stimulus, :that, :topic, :current_segment

    def initialize(raw_stimulus: nil, path: nil, stimulus: nil,
                   that: [UNDEF], topic: [DEFAULT], current_segment: :stimulus )
      @raw_stimulus     = raw_stimulus
      @that             = that.is_a?(String) ? process_string(that) : that
      @topic            = that.is_a?(String) ? process_string(topic) : topic
      @path             = path
      @stimulus         = stimulus
      @current_segment  = current_segment
    end

    def path
      @path ||= to_path
    end

    def to_path
      [
          stimulus,
          THAT, that,
          TOPIC, topic
      ].flatten.compact
    end

    def stimulus
      @stimulus ||= process_string(raw_stimulus) || []
    end

    def stimulus=(value)
      @stimulus = value
    end

    def add(body)
      case body
        when String
          self.stimulus += process_string(body)
        else
          stimulus.push(body)
      end
    end

    def key
      path[0]
    end

    def satisfied?(children)
      path.empty? ||
          (start_that_segment? && context_irrelevant?(children)) ||
          (start_topic_segment? && topic_irrelevant?(children))
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
      return if path.empty?
      @suffix ||= begin

        p  = path[1..-1]     || []
        s  = stimulus[1..-1] || []

        if start_that_segment?
          cs = :that
        elsif start_topic_segment?
          cs = :topic
        else
          cs = current_segment
        end

        Pattern.new(path: p, stimulus: s, that: that, topic: topic, current_segment: cs)
      end
    end

    def topic_segment
      @topic_segment ||= begin
        p = [TOPIC, topic].flatten
        Pattern.new( path: p, stimulus: [], that: that, topic: topic)
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