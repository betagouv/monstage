# frozen_string_literal: true

module SchoolYear
  # period from now until end of school year
  class Floating < Base

    def beginning_of_period
      september_first = Date.new(current_year, 9, 1)
      previous_september_first = Date.new(current_year - 1, 9, 1)
      case current_month
      when january_to_may
        return september_first if last_week_of_may?

        previous_september_first
      when june_to_august ,september_to_december then september_first
      end
    end

    def updated_beginning_of_period
      floating_now = Date.new(current_year, Date.today.month, Date.today.day)
      [floating_now, beginning_of_period].sort.last
    end

    def end_of_period
      case current_month
      when january_to_may
        return shift_day(year: current_year + 1) if last_week_of_may?

        shift_day(year: current_year)
      when june_to_august, september_to_december
        shift_day(year: current_year + 1)
      end
    end

    def shift_day(year:)
      Date.new(year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
    end

    def self.shift_day(year:)
      Date.new(year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
    end

    def self.new_by_year(year:)
      new(date: SchoolYear::Floating.shift_day(year: year))
    end

    private

    def initialize(date:)
      @date = date
    end
  end
end
