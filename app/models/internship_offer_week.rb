class InternshipOfferWeek < ApplicationRecord
  belongs_to :internship_offer
  belongs_to :week

  has_many :internship_applications, dependent: :destroy

  delegate :select_text_method, :human_select_text_method, to: :week
  delegate :max_candidates, to: :internship_offer

  scope :ignore_max_candidates_reached, -> (max_candidates:) {
    where("blocked_applications_count < :max_candidates", max_candidates: max_candidates)
  }

  scope :by_weeks, -> (weeks:) {
    where(week: weeks)
  }

  def has_spots_left?
    blocked_applications_count < max_candidates
  end
end
