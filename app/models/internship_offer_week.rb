# frozen_string_literal: true

class InternshipOfferWeek < ApplicationRecord
  #---------------------------------------
  # blocked_applications_count is a column of InternshipOfferWeek
  # it counts the applications approved for each internship offer week.
  #---------------------------------------
  include Weekable

  belongs_to :internship_offer, counter_cache: true

  has_many :internship_applications, dependent: :destroy

  delegate :max_students_per_group, to: :internship_offer

  # responsability by the week , check student_max_group_size
  scope :applicable, lambda { |school:, internship_offer:|
    by_weeks(weeks: school.weeks)
      .filter_when_max_candidates_reached(max_students_per_group: internship_offer.max_students_per_group)
      .after_current_week
      .includes(:week)
  }

  def self.free_weeks_on_school_year(internship_offer:)
    week_ids = joins(:internship_offer)
               .where(internship_offer:)
               .where.not(blocked_applications_count: internship_offer.max_students_per_group)
               .where(week_id: Week.selectable_on_school_year.ids.to_a)
               .pluck(:week_id)
    Week.where(id: week_ids)
  end
end
