class Week < ApplicationRecord
  has_many :internship_offer_weeks, dependent: :destroy
  has_many :internship_offers, through: :internship_offer_weeks

  has_many :school_internship_weeks, dependent: :destroy
  has_many :schools, through: :school_internship_weeks

  scope :from_date_to_date_for_year, -> (from, to, year) {
    where(year: year).where("number BETWEEN ? AND ?", from.cweek, to.cweek)
  }

  scope :from_date_until_end_of_year, -> (from, year) {
    where(year: year).where("number > ?", from.cweek)
  }

  def select_text_method
    week_date = Date.commercial(year, number)
    date_format = '%d/%m/%Y'
    "Semaine #{number} - du #{week_date.beginning_of_week.strftime(date_format)} au #{week_date.end_of_week.strftime(date_format)}"
  end
end
