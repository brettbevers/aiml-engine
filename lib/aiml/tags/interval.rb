require 'active_support/time'
module AIML::Tags
  class Interval < Base


    def to_s(context)
      unless format && style && from && to
        raise AIML::MissingAttribute, "'interval' tag must have 'format', 'style', 'from' and 'to' attributess"
      end
      frmt = format.to_s(context)
      frm = DateTime.strptime(from.to_s(context), frmt)
      t = DateTime.strptime(to.to_s(context), frmt)

      case style.to_s(context)
        when 'minutes'
          (t-frm).to_i*24*60
        when 'hours'
          (t-frm).to_i*24
        when 'days'
          (t-frm).to_i
        when 'weeks'
          (t-frm).to_i/7
        when 'months'
          (t.year-frm.year)*12 + (t.month-frm.month)
        when 'years'
          t.year-frm.year
      end
    end

    def format
      attributes['format']
    end

    def style
      attributes['style']
    end

    def from
      attributes['from']
    end

    def to
      attributes['to']
    end

  end
end
