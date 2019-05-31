# frozen_string_literal: true

class Week < ApplicationRecord
  has_many :internship_offer_weeks, dependent: :destroy
  has_many :internship_offers, through: :internship_offer_weeks

  has_many :school_internship_weeks, dependent: :destroy
  has_many :schools, through: :school_internship_weeks

  scope :from_date_to_date, -> (from:, to:) {
    if from.year == to.year
      where(year: from.year).where('number BETWEEN ? AND ? ', from.cweek, to.cweek)
    else
      where("year = :from_year AND number > :from_week", {from_year: from.year, from_week: from.cweek})
        .or(where("year = :to_year AND number BETWEEN 1 AND :to_week", {to_year: to.year, to_week: to.cweek}))
    end
  }
  scope :from_date_to_date_for_year, lambda { |from, to, year|
    where(year: year).where('number BETWEEN ? AND ?', from.cweek, to.cweek)
  }

  scope :from_date_until_end_of_year, lambda { |from, year|
    where(year: year).where('number > ?', from.cweek)
  }

  WEEK_DATE_FORMAT = '%d/%m/%Y'

  # to, strip, join with space otherwise multiple spaces can be outputted,
  # then within html it is concatenated [html logic], but capybara fails to find this content
  def short_select_text_method
    ['du', beginning_of_week, 'au', end_of_week]
      .map(&:to_s)
      .map(&:strip)
      .join(' ')
  end

  def human_select_text_method
    ['Semaine du', beginning_of_week, 'au', end_of_week]
      .map(&:to_s)
      .map(&:strip)
      .join(' ')
  end

  def select_text_method
    ['Semaine', number, '- du', beginning_of_week, 'au', end_of_week]
      .map(&:to_s)
      .map(&:strip)
      .join(' ')
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

  def self.current
    current_date = Date.today
    Week.find_by(number: current_date.cweek, year: current_date.year)
  end
end
