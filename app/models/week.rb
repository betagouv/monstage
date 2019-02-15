class Week < ApplicationRecord
  has_many :internship_offer_weeks
  has_many :internship_offers, through: :internship_offer_weeks
  scope :from_date_to_date_for_year, -> (from, to, year) {
    where(year: year).where("number BETWEEN ? AND ?", from.cweek, to.cweek)
  }

  scope :from_date_until_end_of_year, -> (from, year) {
    where(year: year).where("number > ?", from.cweek)
  }
end
