class Week < ApplicationRecord
  has_many :internship_offer_weeks
  has_many :internship_offers, through: :internship_offer_weeks
end
