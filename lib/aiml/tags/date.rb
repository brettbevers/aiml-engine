require 'active_support/time'
module AIML::Tags
  class Date < Base

    def to_s(context=nil)
      unless format
        raise AIML::MissingAttribute, "'date' tag must have attribute 'format'"
      end
      old_timezone = Time.zone
      if timezone
        Time.zone = ActiveSupport::TimeZone[ timezone.to_s(context).to_i ]
      end
      result = Time.now.in_time_zone
      result.strftime(format.to_s(context))
    ensure
      Time.zone = old_timezone
    end

    def inspect
      "date -> #{format}"
    end

    def format
      attributes['format']
    end

    def timezone
      attributes['timezone']
    end

  end
end
