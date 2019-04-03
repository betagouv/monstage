class InternshipOfferWeek < ApplicationRecord
  belongs_to :internship_offer
  counter_culture :internship_offer,
                  column_name: proc  { |model| model.blocked_applications_count > 0 ? 'blocked_weeks_count' : nil }

  belongs_to :week

  has_many :internship_applications

  delegate :select_text_method, to: :week
  delegate :max_candidates, to: :internship_offer

  scope :ignore_max_candidates_reached, -> (max_candidates:) {
    where("blocked_applications_count < :max_candidates", max_candidates: max_candidates)
  }

  scope :by_weeks, -> (weeks:) {
    where(week: weeks)
  }

  def has_spots_left?
    internship_applications.where(aasm_state: 'approved').count < max_candidates
  end
end
