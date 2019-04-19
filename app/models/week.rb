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

  WEEK_DATE_FORMAT = '%d/%m/%Y'
  def select_text_method
    "Semaine #{number} - du #{beginning_of_week} au #{end_of_week}"
  end

  def week_date
    Date.commercial(year, number)
  end

  def beginning_of_week
    I18n.localize(week_date.beginning_of_week, format: :human_mm_dd)
  end

  def end_of_week
    I18n.localize(week_date.end_of_week, format: :human_mm_dd)
  end
end
