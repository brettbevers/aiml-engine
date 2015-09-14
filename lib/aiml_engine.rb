require_relative "aiml_engine/version"
require_relative "string"
require 'engtagger'

module AimlEngine
  THAT    = '<that>'
  TOPIC   = '<topic>'
  UNDEF   = 'UNDEF'
  DEFAULT = 'DEFAULT'

  TAGGER = EngTagger.new
end

require_relative "aiml_engine/facade"
