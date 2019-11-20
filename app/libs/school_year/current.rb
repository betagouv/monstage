module SchoolYear
  # period from beginning of school year until end
  class Current < Base
    def beginning_of_period
      case current_month
      when january_to_may then Date.new(current_year - 1, 9, 1)
      when june_to_august then Date.new(current_year, 9, 1)
      when september_to_december then Date.new(current_year, 9, 1)
      end
    end

    def end_of_period
      case current_month
      when january_to_may then Date.new(current_year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      when june_to_august then Date.new(current_year + 1, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      when september_to_december then Date.new(current_year + 1, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      end
    end

    private
    def initialize()
      @date = Date.today
    end
  end
end
