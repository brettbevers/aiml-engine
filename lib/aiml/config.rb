module AIML
  class Config

    attr_reader :custom_tag_map

    def initialize
      @custom_tag_map = {}
    end

    def register_tag(klass)
      klass.tag_names.each do |tag_name|
        tag_name = tag_name.to_s if tag_name.is_a?(Symbol)
        custom_tag_map[tag_name] = klass
      end
    end

  end
end