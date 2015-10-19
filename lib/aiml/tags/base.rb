module AIML::Tags
  class Base

    def self.tag_names
      return @tag_names if @tag_names
      str = name.split('::').last
      str.gsub!(/([A-Z]+)([A-Z][a-z\d])/,'\1_\2')
      str.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      str.downcase!
      @tag_names = [ str ]
    end

    attr_reader :body, :local_name, :attributes

    def initialize(local_name=nil, attributes={})
      @local_name = local_name
      @attributes = attributes
      @body = []
    end

    def add(object)
      body.push(object)
    end

    def to_s(context)
      body.map{ |token| token.to_s(context) }.join
    end

    def inspect
      "#{self.class.tag_names.first} -> #{body.map(&:inspect).join(' ')}"
    end

    def name(context=nil)
      get_attribute('name', context)
    end

    def name?
      attribute_present?('name')
    end

    def var(context=nil)
      get_attribute('var', context)
    end

    def var?
      attribute_present?('var')
    end

    def value(context=nil)
      get_attribute('value', context)
    end

    def value?
      attribute_present?('value')
    end

    def index(context=nil)
      get_attribute('index', context)
    end

    def index?
      attribute_present?('index')
    end

    def attribute_present?(key)
      attributes.key?(key)
    end

    def get_attribute(key, context=nil)
      return unless result = attributes[key]
      context ? result.to_s(context) : result
    end

  end
end
