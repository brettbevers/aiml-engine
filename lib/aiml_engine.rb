require_relative "version"
require_relative "string"
require 'engtagger'

module AIML
  THAT    = '<that>'
  TOPIC   = '<topic>'
  UNDEF   = 'UNDEF'
  DEFAULT = 'DEFAULT'

  TAGGER = EngTagger.new

  class TagMismatch < StandardError; end
  class MissingParentTag < StandardError; end
end

require_relative "aiml/facade"
