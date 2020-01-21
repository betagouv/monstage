module Presenters
  class WeekList

    def to_s
      weeks.map(&:long_select_text_method)
           .join("\n")
    end

    private
    attr_reader :weeks
    def initialize(weeks:)
      @weeks = weeks
    end
  end
end
