require_relative "version"
require_relative "string"
require 'engtagger'

module AIML
  THAT    = '<that>'
  TOPIC   = '<topic>'
  UNDEF   = 'UNDEF'
  DEFAULT = 'DEFAULT'

  TAGGER = EngTagger.new

  class TagError < StandardError; end
  class TagMismatch < TagError; end
  class MissingParentTag < TagError; end
end

require_relative "aiml/facade"
