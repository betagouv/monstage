# frozen_string_literal: true

class InternshipOfferWeek < ApplicationRecord
  include Weekable

  belongs_to :internship_offer, counter_cache: true

  has_many :internship_applications, dependent: :destroy

  delegate :max_student_group_size, to: :internship_offer

  # responsability by the week , check student_max_group_size
  scope :applicable, lambda { |user:, internship_offer:|
    by_weeks(weeks: user.school.weeks)
      .ignore_max_candidates_reached(max_student_group_size: internship_offer.max_student_group_size)
      .after_current_week
      .includes(:week)
  }
end
