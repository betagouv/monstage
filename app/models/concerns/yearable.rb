module Yearable
  extend ActiveSupport::Concern

  included do
    scope :during_current_year, -> {
      during_year(year: Date.today.month <= SchoolYear::MONTH_OF_YEAR_SHIFT ? Date.today.year - 1 : Date.today.year)
    }

    # year parameter is the first year from a school year.
    # For example, year would be 2019 for school year 2019/2020
    scope :during_year, -> (year:) {
      where("created_at > :date_begin", date_begin: Date.new(year, SchoolYear::MONTH_OF_YEAR_SHIFT, SchoolYear::DAY_OF_YEAR_SHIFT))
      .where("created_at <= :date_end", date_end: Date.new(year + 1, SchoolYear::MONTH_OF_YEAR_SHIFT, SchoolYear::DAY_OF_YEAR_SHIFT))
    }
  end
end
