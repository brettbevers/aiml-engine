require_relative 'graph_master'
require_relative 'parser'
require_relative 'set_parser'
require_relative 'map_parser'
require_relative 'history'
require_relative 'utils'
require_relative 'tags/pattern'
require_relative 'normalizer_parser'
require_relative 'denormalizer_parser'

module AIML
  class Facade

    INPUT_SEPARATOR = /(?<!\sdr|\smr|\sms|\smrs|\se\.g|\si\.e|\setc|\ssr|\sjr|\sst|\save|\srd|\sdept|\smt|\svs|\sinc|\sp\.s|\sa\.m|\sp\.m)(\.\s+|\?\s+|!\s+|\n)/i

    attr_reader :context, :graph_master, :parser, :set_parser, :map_parser, :default_properties, :normalizer, :denormalizer

    def initialize(cache = nil)
      @graph_master       = GraphMaster.new
      @parser             = Parser.new(@graph_master)
      @set_parser         = SetParser.new(@graph_master)
      @map_parser         = MapParser.new(@graph_master)
      @context            = History.new
      @default_properties = Hash.new
      @normalizer_parser         = NormalizerParser.new(@graph_master)
      @denormalizer_parser       = DenormalizerParser.new(@graph_master)
    end

    def learn(files)
      FileFinder::find_aiml(files).each{|f| File.open(f,'r'){|io| parser.parse io} }
      FileFinder::find_sets(files).each{|f| File.open(f,'r'){|io| set_parser.parse io} }
      FileFinder::find_maps(files).each{|f| File.open(f,'r'){|io| map_parser.parse io} }

      FileFinder::find_properties(files).each do |f|
        File.open(f,'r') do |io|
          properties = Hash[YAML::load(io)]
          default_properties.merge! properties
          context.load_properties(properties)
        end
      end

      if normalizations = FileFinder::find_normalizations(files)
        File.open(normalizations,'r'){ |io| normalizer_parser.parse io }
      end

      if denormalizations = FileFinder::find_denormalizations(files)
        File.open(denormalizations,'r'){ |io| denormalizer_parser.parse io }
      end

    end

    def loading(theCacheFilename='cache')
      cache = Cache::loading(theCacheFilename)
      @graph_master = cache if cache
    end

    def merging(theCacheFilename='cache')
      cache = Cache::loading(theCacheFilename)
      @graph_master.merge(cache) if cache
    end

    def dumping(theCacheFilename='cache')
      Cache::dumping(theCacheFilename,@graph_master)
    end

    def load_context(data)
      data = data.with_indifferent_access
      @context = History.new(data)
      context.load_properties(default_properties)
      context
    end

    def dump_context
      context.dump
    end

    def get_reaction(raw_stimulus)
      input = process_input(raw_stimulus)
      context.update_input(input)
      response = input.map do |sentence|
        sentence = graph_master.normalize(sentence)
        pattern = AIML::Tags::Pattern.new(sentence: sentence, that: context.that, topic: context.topic)
        graph_master.render_reaction(pattern, context)
      end
      context.update_response(response)
      return response.join(' ')
    end

    def to_s
      @graph_master.to_s
    end

    def self.process_input(raw_stimulus)
      raw_stimulus.split(INPUT_SEPARATOR).map{ |s| s.strip.empty? ? nil : s.strip }.compact
    end

    def process_input(raw_stimulus)
      self.class.process_input(raw_stimulus)
    end

  end
end
