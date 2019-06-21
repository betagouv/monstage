# frozen_string_literal: true

class SchoolYear
  MONTH_OF_YEAR_SHIFT = 5
  DAY_OF_YEAR_SHIFT = 31

  def beginning_of_period
    case current_month
    when january_to_may
      return SchoolYear.new(date: Date.new(current_year, 6, 1)).beginning_of_period if last_week_of_may?

      Date.today
    when june_to_august then Date.new(current_year, 9, 1)
    when september_to_december then Date.today
    end
  end

  def end_of_period
    case current_month
    when january_to_may
      return SchoolYear.new(date: Date.new(current_year, 6, 1)).end_of_period if last_week_of_may?

      Date.new(current_year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
    when june_to_august,
           september_to_december
      Date.new(current_year + 1,
               MONTH_OF_YEAR_SHIFT,
               DAY_OF_YEAR_SHIFT)
    end
  end

  private

  attr_reader :date

  def initialize(date:)
    @date = date
  end

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
    last_day_of_may = Date.new(current_year, current_month, 31)
    date.between?(last_day_of_may.beginning_of_week, last_day_of_may.end_of_week)
  end
end
