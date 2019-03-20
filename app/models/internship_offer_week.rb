class InternshipOfferWeek < ApplicationRecord
  belongs_to :internship_offer
  belongs_to :week

  has_many :internship_applications

  delegate :select_text_method, to: :week
end
