module Reporting
  class Week < ApplicationRecord
    include FormatableWeek
    def readonly?
      true
    end

    has_many :school_internship_weeks
    has_many :schools, through: :school_internship_weeks

    scope :school_weeks, -> {
      Week.selectable_on_school_year
          .select("count(school_id) as school_count_per_week, weeks.id, weeks.number, weeks.year")
          .left_joins(:school_internship_weeks)
          .group("weeks.id")
    }

    scope :internship_offer_weeks, -> {
      Week.selectable_on_school_year.select("count(internship_offer_id) as internship_offers_count_per_week, weeks.id, weeks.number, weeks.year").left_joins(:internship_offer_weeks).group("weeks.id").order(:id)
    }
  end
end
