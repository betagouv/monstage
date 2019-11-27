# frozen_string_literal: true

# Calendar weeks
class Week < ApplicationRecord
  has_many :internship_offer_weeks, dependent: :destroy
  has_many :internship_offers, through: :internship_offer_weeks

  has_many :school_internship_weeks, dependent: :destroy
  has_many :schools, through: :school_internship_weeks

  scope :from_date_to_date, lambda { |from:, to:|
    query = from_date_for_current_year(from: from)
    return query.to_date_for_current_year(to: to) if from.year == to.year

    query.or(to_date_for_current_year(to: to))
  }

  scope :by_year, lambda { |year:|
    where(year: year)
  }

  scope :from_date_for_current_year, lambda { |from:|
    by_year(year: from.year).where('number > :from_week', from_week: from.cweek)
  }

  scope :to_date_for_current_year, lambda { |to:|
    by_year(year: to.year).where('number <= :to_week', to_week: to.cweek)
  }


  scope :selectable_from_now_until_end_of_school_year, lambda {
    school_year = SchoolYear::Floating.new(date: Date.today)

    from_date_to_date(from: school_year.beginning_of_period,
                           to: school_year.end_of_period)
  }

  scope :selectable_on_school_year, lambda {
    school_year = SchoolYear::Current.new

    from_date_to_date(from: school_year.beginning_of_period,
                      to: school_year.end_of_period)
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

  rails_admin do
    export do
      field :number
      field :year
    end
  end
end
