class InternshipOfferWeek < ApplicationRecord
  belongs_to :internship_offer
  belongs_to :week

  delegate :select_text_method, to: :week
end
