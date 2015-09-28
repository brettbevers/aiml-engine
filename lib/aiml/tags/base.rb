module AIML::Tags
  class Base

    def self.tag_names
      str = name.split('::').last
      str.gsub!(/([A-Z]+)([A-Z][a-z\d])/,'\1_\2')
      str.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      str.downcase!
      [ str ]
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

  end
end
