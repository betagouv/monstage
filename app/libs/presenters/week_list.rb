module Presenters
  class WeekList

    def to_range_as_str
      to_range do |is_first:, is_last:, week:|
        if is_first
          week.beginning_of_week_with_year
        elsif is_last
          week.end_of_week_with_years
        else
          week.long_select_text_method
        end
      end
    end

    def to_range(&renderer)
      first, last = weeks.minmax_by(&:id)

      if weeks.size <= 5
        weeks.map{ |week| yield(is_first: false, is_last: false, week: week) }
             .join(", ")
      else
        [
          "Disponible sur #{weeks.size} semaines :",
          "du #{yield(is_first: true, is_last: false, week: first)}",
          "au #{yield(is_first: false, is_last: true, week: last)}"
        ].join(" ")
      end
    end

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
