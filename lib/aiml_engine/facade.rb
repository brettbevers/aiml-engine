require_relative '../aiml_engine'
require_relative 'graph_master'
require_relative 'aiml_parser'
require_relative 'history'
require_relative 'utils'
require_relative 'pattern'

module AimlEngine
  class Facade

    attr_reader :history, :graph_master

    def initialize(cache = nil)
      @graph_master = GraphMaster.new
      @parser       = AimlParser.new(@graph_master)
      @history      = History.new
    end

    def learn(files)
      AimlFinder::find(files).each{|f| File.open(f,'r'){|f| @parser.parse f} }
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

    def get_reaction(raw_stimulus)
      history.update_stimulus(raw_stimulus)
      pattern = Pattern.new(raw_stimulus, history)
      result = graph_master.render_reaction(pattern.to_path)
      history.updateResponse(result)
      return result
    end

    def to_s
      @graph_master.to_s
    end

  end
end
