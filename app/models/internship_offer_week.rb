# frozen_string_literal: true

class InternshipOfferWeek < ApplicationRecord
  include Weekable

  belongs_to :internship_offer, counter_cache: true

  has_many :internship_applications, dependent: :destroy

  delegate :max_candidates, to: :internship_offer

  scope :applicable, lambda { |user:, internship_offer:|
    by_weeks(weeks: user.school.weeks)
      .ignore_max_candidates_reached(max_candidates: internship_offer.max_candidates)
      .after_current_week
      .includes(:week)
  }
end
