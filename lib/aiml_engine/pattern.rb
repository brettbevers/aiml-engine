module AimlEngine
  class Pattern

    attr_reader :raw_stimulus, :history

    def initialize(raw_stimulus, history)
      @raw_stimulus = raw_stimulus
      @history = history
    end

    def to_path
      [
          process_string(raw_stimulus),
          THAT, process_string(history.that),
          TOPIC, process_string(history.topic)
      ].flatten
    end

    private

    def process_string(str)
      str.upcase.split(/\s+/)
    end

  end
end