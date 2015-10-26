module AIML::Tags
  class Pattern

    def self.tag_names
      %w{ pattern }
    end

    SEGMENTER = /^\s*(.*?)?(\s*(?<!#{AIML::THAT})#{AIML::THAT}\s+(.*?))?(\s*(?<!#{AIML::TOPIC})#{AIML::TOPIC}\s+(.*?))?\s*$/

    attr_accessor :sentence, :that, :topic, :current_segment_type

    def initialize(sentence: nil, path: nil, stimulus: nil,
                   that: [AIML::UNDEF], topic: [AIML::DEFAULT], current_segment_type: :stimulus)
      @sentence = sentence
      @that = process(that)
      @topic = process(topic)
      @path = path
      @stimulus = stimulus
      @current_segment_type = current_segment_type
      @suffixes = {}
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
      @stimulus ||= process(sentence) || []
    end
    alias_method :body, :stimulus

    def stimulus=(value)
      @stimulus = value
    end

    def add(object)
      case object
        when String
          self.stimulus += process(object)
        else
          stimulus.push(object)
      end
    end

    def key
      @key ||= path[0]
    end

    def satisfied?(children)
      path.empty? ||
          ( start_that_segment? && context_irrelevant?(children) ) ||
          ( start_topic_segment? && topic_irrelevant?(children) )
    end

    def qualified?(children)
          ( children.key?(AIML::THAT) && start_that_segment? && !that_irrelevant?(children) ) ||
          ( children.key?(AIML::TOPIC) && start_topic_segment? && !topic_irrelevant?(children) )
    end

    def start_context_segment?
      @start_context_segment ||= ( start_that_segment? || start_topic_segment? )
    end

    def start_that_segment?
      @start_that_segment ||= key == AIML::THAT
    end

    def start_topic_segment?
      @start_topic_segment ||= key == AIML::TOPIC
    end

    def null_key?
      @null_key ||= null?(key)
    end

    def return?
      key == AIML::PATTERN_RETURN
    end

    def null?(value)
      [AIML::DEFAULT, AIML::UNDEF].include?(value)
    end

    def key_matchable?
      @key_matchable ||= !( key.nil? || null_key? || start_context_segment? )
    end

    def context_irrelevant?(children)
      that_irrelevant?(children) && topic_irrelevant?(children)
    end

    def topic_irrelevant?(children)
      ( !children.key?(AIML::TOPIC) || null?(topic.first) ) &&
          ( !children.key?("#") || topic_irrelevant?(children["#"].children) ) &&
          ( !children.key?("^") || topic_irrelevant?(children["^"].children) )
    end

    def that_irrelevant?(children)
      ( !children.key?(AIML::THAT) || null?(that.first) ) &&
          ( !children.key?("#") || that_irrelevant?(children["#"].children) ) &&
          ( !children.key?("^") || that_irrelevant?(children["^"].children) )
    end

    def safe_suffix(index=1)
      suffix(index)
    rescue AIML::ExceededEndOfPattern
      nil
    end

    def suffix(index=1)
      @suffixes[index] ||= begin
        raise AIML::ExceededEndOfPattern if path.size < index
        p = path[index..-1] || []

        if start_that_segment?
          cs = :that
        elsif start_topic_segment?
          cs = :topic
        else
          cs = current_segment_type
        end

        AIML::Tags::Pattern.new(path: p, that: that, topic: topic, current_segment_type: cs)
      end
    end

    def copy
      attrs = {
          sentence: (sentence.dup if sentence),
          path:     (path.dup     if path),
          that:     (that.dup     if that),
          topic:    (topic.dup    if topic),
          current_segment_type: current_segment_type
      }
      if stimulus
        stimulus_copy = stimulus.map do |token|
          if token.respond_to? :copy
            token.copy
          elsif token.respond_to? :dup
            token.dup
          else
            token
          end
        end
        attrs[:stimulus] = stimulus_copy
      end
      AIML::Tags::Pattern.new(attrs)
    end

    def next_segment
      return @next_segment if @next_segment
      if start_context_segment?
        @next_segment = suffix.next_segment
        return @next_segment
      end
      p = if current_segment_size > 0
            path[current_segment_size..-1]
          else
            []
          end
      @next_segment = AIML::Tags::Pattern.new(path: p, stimulus: [], that: that, topic: topic,
                                              current_segment_type: current_segment_type)
    end

    def default_topic?
      @default_topic ||= topic == AIML::DEFAULT
    end

    def current_segment_size
      @current_segment_size ||= current_segment.size
    end

    def current_segment
      @current_segment ||= begin
        result = []
        memo = self
        while memo.key_matchable? || memo.null_key?
          result << memo.key
          memo = memo.suffix
        end
        result
      end
    end

    def self.process_string(str)
      return unless str
      str.strip.upcase.
          gsub(/\b[^a-zA-Z0-9'_*\$\^#-]+\b/,' ').
          gsub(/(^[^a-zA-Z0-9'_*\$\^#-]+|[^a-zA-Z0-9'_*\$\^#-]+$)/,'').
          split(/\s+/)
    end

    def self.process_array(ary)
      ary.map{|obj| process(obj)}.flatten
    end

    def self.process(obj)
      case obj
        when String
          process_string(obj)
        when Array
          process_array(obj)
        else
          obj
      end
    end

    def process(str)
      self.class.process(str)
    end

    def reprocess_stimulus
      old_stimulus = stimulus
      self.stimulus = nil
      old_stimulus.each{ |token| add(token) }
      stimulus
    end

  end
end



