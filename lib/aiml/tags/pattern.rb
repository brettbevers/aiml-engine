module AIML::Tags
  class Pattern

    def self.tag_names
      %w{ pattern }
    end

    SEGMENTER = /^\s*(.*?)?(\s*(?<!#{AIML::THAT})#{AIML::THAT}\s+(.*?))?(\s*(?<!#{AIML::TOPIC})#{AIML::TOPIC}\s+(.*?))?\s*$/

    attr_accessor :raw_stimulus, :that, :topic, :current_segment

    def initialize(raw_stimulus: nil, path: nil, stimulus: nil,
                   that: [AIML::UNDEF], topic: [AIML::DEFAULT], current_segment: :stimulus)
      @raw_stimulus = raw_stimulus
      @that = that.is_a?(String) ? process_string(that) : that
      @topic = that.is_a?(String) ? process_string(topic) : topic
      @path = path
      @stimulus = stimulus
      @current_segment = current_segment
    end

    def path
      @path ||= to_path
    end

    def to_path
      [
          stimulus,
          AIML::THAT, that,
          AIML::TOPIC, topic
      ].flatten.compact
    end

    def stimulus
      @stimulus ||= process_string(raw_stimulus) || []
    end
    alias_method :body, :stimulus

    def stimulus=(value)
      @stimulus = value
    end

    def add(object)
      case object
        when String
          self.stimulus += process_string(object)
        else
          stimulus.push(object)
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
      key == AIML::THAT
    end

    def start_topic_segment?
      key == AIML::TOPIC
    end

    def null_key?
      [AIML::DEFAULT, AIML::UNDEF].include?(key)
    end

    def key_matchable?
      !null_key? && !start_context_segment?
    end

    def context_irrelevant?(children)
      !children.key?(AIML::THAT) && !children.key?(AIML::TOPIC)
    end

    def topic_irrelevant?(children)
      !children.key?(AIML::TOPIC)
    end

    def suffix
      return if path.empty?
      @suffix ||= begin

        p = path[1..-1] || []
        s = stimulus[1..-1] || []

        if start_that_segment?
          cs = :that
        elsif start_topic_segment?
          cs = :topic
        else
          cs = current_segment
        end

        AIML::Tags::Pattern.new(path: p, stimulus: s, that: that, topic: topic, current_segment: cs)
      end
    end

    def topic_segment
      @topic_segment ||= begin
        p = [AIML::TOPIC, topic].flatten
        AIML::Tags::Pattern.new(path: p, stimulus: [], that: that, topic: topic)
      end
    end

    def default_topic?
      topic == AIML::DEFAULT
    end

    def self.process_string(str)
      return unless str
      str.strip.upcase.
          gsub(/\b[^a-zA-Z0-9'_*-]+\b/,' ').
          gsub(/(^[^a-zA-Z0-9'_*-]+|[^a-zA-Z0-9'_*-]+$)/,'').
          split(/\s+/)
    end

    def process_string(str)
      self.class.process_string(str)
    end

    def reprocess_stimulus
      old_stimulus = stimulus
      self.stimulus = nil
      old_stimulus.each{ |token| add(token) }
      stimulus
    end

  end
end



