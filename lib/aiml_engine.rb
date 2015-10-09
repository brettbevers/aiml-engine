require_relative "version"
require_relative "string"
require 'engtagger'
require_relative 'aiml/config'

module AIML
  THAT    = '<that>'
  TOPIC   = '<topic>'
  UNDEF   = 'UNDEF'
  DEFAULT = 'DEFAULT'

  TAGGER = EngTagger.new

  class TagError < StandardError; end
  class TagMismatch < TagError; end
  class MissingParentTag < TagError; end
  class ExceededEndOfPattern < StandardError; end

  @@config = ::AIML::Config.new

  def self.config
    yield @@config if block_given?
    @@config
  end

end

require_relative "aiml/facade"
