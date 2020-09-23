# frozen_string_literal: true

class InternshipOfferInfoWeek < ApplicationRecord
  include Weekable
  belongs_to :internship_offer_info, counter_cache: true
  
  delegate :max_candidates, to: :internship_offer_info

  scope :applicable, lambda { |user:, internship_offer_info:|
    by_weeks(weeks: user.school.weeks)
      .ignore_max_candidates_reached(max_candidates: internship_offer_info.max_candidates)
      .after_current_week
      .includes(:week)
  }
end
