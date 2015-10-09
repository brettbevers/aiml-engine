require_relative 'graph_master'
require_relative 'parser'
require_relative 'set_parser'
require_relative 'history'
require_relative 'utils'
require_relative 'tags/pattern'

module AIML
  class Facade

    attr_reader :context, :graph_master

    def initialize(cache = nil)
      @graph_master = GraphMaster.new
      @parser       = Parser.new(@graph_master)
      @set_parser   = SetParser.new(@graph_master)
      @context      = History.new
    end

    def learn(files)
      FileFinder::find_aiml(files).each{|f| File.open(f,'r'){|io| @parser.parse io} }
      FileFinder::find_sets(files).each{|f| File.open(f,'r'){|io| @set_parser.parse io} }
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
      @context = History.new(data.with_indifferent_access)
    end

    def dump_context
      context.dump
    end

    def get_reaction(raw_stimulus)
      context.update_stimulus(raw_stimulus)
      pattern = AIML::Tags::Pattern.new(raw_stimulus: raw_stimulus, that: context.that, topic: context.topic)
      result = graph_master.render_reaction(pattern, context)
      context.update_response(result)
      return result
    end

    def to_s
      @graph_master.to_s
    end

  end
end
