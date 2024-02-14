# frozen_string_literal: true

# Calendar weeks
class Week < ApplicationRecord
  include FormatableWeek
  WORKING_WEEK_DURATION = 5
  has_many :internship_offer_weeks, dependent: :destroy,
                                    foreign_key: :week_id
  has_many :internship_applications, dependent: :destroy,
                                    foreign_key: :week_id

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

  scope :from_now, lambda {
    current_date = Date.current
    if current_date.cweek == 53 && current_date.month == 12
      (where('number = ?', 53).where('year = ?', current_date.year)).or( where('year > ?', current_date.year))
    elsif current_date.cweek == 53 && current_date.month == 1
      where('year >= ?', current_date.year)
    else
      (where('number >= ?', current_date.cweek).where('year >= ?', current_date.year)).or(where('year > ?', current_date.year))
    end
  }

  scope :in_the_future, lambda {
    if Date.current.cweek == 53 && Date.current.month == 1
      where('year >= ?', Date.current.year)
    else
      (where('number > ?', Date.current.cweek).where('year >= ?', Date.current.year)).or(where('year > ?', Date.current.year))
    end
  }

  scope :from_date_for_current_year, lambda { |from:|
    by_year(year: from.year).where('number > :from_week', from_week: from.cweek)
  }

  scope :to_date_for_current_year, lambda { |to:|
    by_year(year: to.year).where('number <= :to_week', to_week: to.cweek)
  }

  scope :fetch_from, lambda { |date: |
    number = date.cweek
    year = number == 53 ? date.year - 1 : date.year
    find_by(number: number, year: year)
  }

  scope :selectable_from_now_until_end_of_school_year, lambda {
    school_year = SchoolYear::Floating.new(date: Date.today)

    from_date_to_date(from: school_year.updated_beginning_of_period,
                      to: school_year.end_of_period
    )
  }

  scope :selectable_from_now_until_next_school_year, lambda {
    school_year = SchoolYear::Floating.new(date: Date.today)
    next_year = SchoolYear::Floating.new(date: Date.today + 1.year)

    from_date_to_date(from: school_year.updated_beginning_of_period,
                      to: school_year.end_of_period
    ).or(
      from_date_to_date(from: next_year.beginning_of_period,
                        to: next_year.end_of_period)
      )
  }

  scope :selectable_on_next_school_year, lambda {
    n = Week.current.ahead_of_school_year_start? ? 0 : 1
    school_year = SchoolYear::Floating.new(date: Date.today + n.year)

    from_date_to_date(from: school_year.beginning_of_period,
                      to: school_year.end_of_period)
  }

  scope :of_previous_school_year, lambda {
    school_year = SchoolYear::Floating.new(date: Date.today)
    weeks_of_school_year(school_year: school_year.strict_beginning_of_period.year - 1)
  }

  scope :selectable_for_school_year, lambda { |school_year:|
    weeks_of_school_year(school_year: school_year.strict_beginning_of_period.year)
  }

  scope :selectable_on_specific_school_year, lambda { |school_year:|
    weeks_of_school_year(school_year: school_year.beginning_of_period.year)
  }

  scope :selectable_on_school_year, lambda {
    school_year = SchoolYear::Current.new

    from_date_to_date(from: school_year.beginning_of_period,
                      to: school_year.end_of_period)
  }

  scope :selectable_on_school_year_when_editing, lambda {
    if Week.current.ahead_of_school_year_start?
      selectable_from_now_until_end_of_school_year
    else
      selectable_from_now_until_end_of_school_year.or(selectable_on_next_school_year)
    end
  }

  scope :weeks_of_school_year, lambda { |school_year:|
    first_week_of_september = Date.new(school_year, 9, 1).cweek
    last_day_of_may_week    = Date.new(school_year + 1, 5, 31).cweek

    where('number >= ?', first_week_of_september).where( year: school_year)
     .or(where('number <= ?', last_day_of_may_week).where( year: school_year + 1))
  }

  scope :available_for_student, lambda { |user:|
    where(id: user.school.weeks)
  }

  WEEK_DATE_FORMAT = '%d/%m/%Y'

  def self.current
    now = Date.today

    fetch_from(date: Date.today)
  end

  def self.next
    fetch_from(date: Date.today + 1.week)
  end

  def ahead_of_school_year_start?
    return false  if number > 50 && number < 2 # week 53 justifies this

    week_date.beginning_of_week >= Date.new(year, 5, 31) &&
      week_date.end_of_week < Date.new(year, 9, 1)
  end

  def <(other_week)
    year < other_week.year || (year == other_week.year && number < other_week.number)
  end

  rails_admin do
    export do
      field :number
      field :year
    end
  end

  def consecutive_to?(other_week)
    self.id.to_i == other_week.id.to_i + 1
  end
end
