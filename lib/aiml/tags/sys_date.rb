module AIML
  module Tags
    class Sys_Date < Base
      def to_s(context=nil)
        Date.today.to_s
      end

      def inspect
        "date -> #{Date.today.to_s}"
      end
    end
  end
end
