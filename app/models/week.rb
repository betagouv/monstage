class Week < ApplicationRecord
  has_many :internship_offer_weeks
  has_many :internship_offers, through: :internship_offer_weeks
    # .where(number: Date.today.cweek..Date.new(current_year, 5, 1).cweek)
  # scope :window_from_january_until_may, -> {
  #   where(year: Date.now.year)
  # }
  #
  # scope :window_from_septembre_until_may_next_year, -> {
  #   where(year: Date.now.year).where(number: Date.new(current_year, 9, 1).cweek..Date.new(current_year+1, 5, 1).cweek)
  # }
end
