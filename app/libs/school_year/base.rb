# frozen_string_literal: true

module SchoolYear
  class Base
    MONTH_OF_YEAR_SHIFT = 5
    DAY_OF_YEAR_SHIFT = 31

    def between_june_to_august?
      june_to_august.member?(current_month)
    end

    private

    attr_reader :date

    def current_year
      date.year
    end

    def current_month
      date.month
    end

    def january_to_may
      1..5
    end

    def june_to_august
      6..8
    end

    def september_to_december
      9..12
    end

    def last_week_of_may?
      last_day_of_may = Date.new(current_year, 5, 31)
      date.between?(last_day_of_may.beginning_of_week, last_day_of_may.end_of_week)
    end
  end
end
