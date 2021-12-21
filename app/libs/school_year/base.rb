# frozen_string_literal: true

module SchoolYear
  class Base
    YEAR_START          = 2019
    MONTH_OF_YEAR_SHIFT = 5
    DAY_OF_YEAR_SHIFT   = 31

    def strict_beginning_of_period
      case current_month
      when january_to_may, june_to_august
        Date.new(current_year - 1, 9, 1)
      when september_to_december
        Date.new(current_year, 9, 1)
      end
    end

    def between_june_to_august?
      june_to_august.member?(current_month)
    end

    def range
      beginning_of_period..(self.next_year).beginning_of_period
    end

    def next_year
      SchoolYear::Floating.new_by_year(year: end_of_period.year)
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
      1..MONTH_OF_YEAR_SHIFT
    end

    def june_to_august
      6..8
    end

    def september_to_december
      9..12
    end

    def last_week_of_may?
      last_day_of_may = Date.new(current_year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      date.between?(last_day_of_may.beginning_of_week, last_day_of_may.end_of_week)
    end
  end
end
