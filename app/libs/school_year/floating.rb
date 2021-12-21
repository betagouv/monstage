# frozen_string_literal: true

module SchoolYear
  # period from now until end of school year
  class Floating < Base

    def beginning_of_period
      case current_month
      when january_to_may
        return Floating.new(date: Date.new(current_year, 6, 1)).beginning_of_period if last_week_of_may?

        Date.new(current_year, Date.today.month, Date.today.day)
      when june_to_august then Date.new(current_year, 9, 1)
      when september_to_december then Date.new(current_year, Date.today.month, Date.today.day)
      end
    end

    def end_of_period
      case current_month
      when january_to_may
        return Floating.new(date: Date.new(current_year, 6, 1)).end_of_period if last_week_of_may?

        SchoolYear::Floating.shift_day(year: current_year)
      when june_to_august,
             september_to_december
        SchoolYear::Floating.shift_day(year: current_year + 1)
      end
    end


    def self.new_by_year(year:)
      new(date: SchoolYear::Floating.shift_day(year: year))
    end

    def self.shift_day(year:)
      Date.new(year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
    end

    private
    def initialize(date:)
      @date = date
    end
  end
end
