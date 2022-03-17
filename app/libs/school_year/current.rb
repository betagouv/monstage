# frozen_string_literal: true

module SchoolYear
  # period from beginning of school year until end
  class Current < Base

    def beginning_of_period
      september_first = Date.new(current_year, SEPTEMBER, FIRST)
      previous_september_first = Date.new(current_year - 1, SEPTEMBER, FIRST)

      case current_month
      when january_to_may then
        return september_first if last_week_of_may?

        previous_september_first
      when june_to_august, september_to_december then september_first
      end
    end

    def end_of_period
      year_end_date = Date.new(current_year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      next_year_end_date = Date.new(current_year + 1, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      case current_month
      when january_to_may then
        return next_year_end_date if last_week_of_may?

        year_end_date
      when june_to_august, september_to_december then next_year_end_date
      end
    end

    private

    def initialize
      @date = Date.today
    end
  end
end
