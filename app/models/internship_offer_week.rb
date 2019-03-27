class InternshipOfferWeek < ApplicationRecord
  belongs_to :internship_offer
  belongs_to :week

  has_many :internship_applications

  delegate :select_text_method, to: :week
  delegate :max_candidates, to: :internship_offer

  def has_spots_left?
    internship_applications.where(aasm_state: 'approved').count < max_candidates
  end
end
