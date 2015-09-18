module AIML::Tags
  class Base

    def self.tag_names
      raise "#tag_names must be implemented"
    end

  end
end
