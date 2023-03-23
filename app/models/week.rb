# frozen_string_literal: true

# Calendar weeks
class Week < ApplicationRecord
  include FormatableWeek
  has_many :internship_offer_weeks, dependent: :destroy,
                                    foreign_key: :week_id
  has_many :internship_applications, dependent: :destroy,
                                    foreign_key: :week_id

  has_many :internship_offers, through: :internship_offer_weeks

  has_many :internship_offer_info_weeks, dependent: :destroy,
                                         foreign_key: :internship_offer_info_id
  has_many :internship_offer_infos, through: :internship_offer_info_weeks

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
    (where('number >= ?', Date.current.cweek).where('year >= ?', Date.current.year)).or(where('year > ?', Date.current.year))
  }

  scope :in_the_future, lambda {
    (where('number > ?', Date.current.cweek).where('year >= ?', Date.current.year)).or(where('year > ?', Date.current.year))
  }

  scope :from_date_for_current_year, lambda { |from:|
    by_year(year: from.year).where('number > :from_week', from_week: from.cweek)
  }

  scope :to_date_for_current_year, lambda { |to:|
    by_year(year: to.year).where('number <= :to_week', to_week: to.cweek)
  }

  scope :fetch_from, lambda { |date: |
    find_by(number: date.cweek, year: date.year)
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

  scope :next_school_year, lambda {
    school_year = SchoolYear::Floating.new(date: Date.today + 1.year)

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

  scope :weeks_of_school_year, lambda { |school_year:|
    first_week_of_september = Date.new(school_year, 9, 1).cweek
    last_day_of_may_week    = Date.new(school_year + 1, 5, 31).cweek

    where('number >= ?', first_week_of_september).where( year: school_year)
     .or(where('number <= ?', last_day_of_may_week).where( year: school_year + 1))
  }

  scope :available_for_student, lambda { |user:|
    where(id: user.school.weeks)
    # .where(id: internship_offer.weeks)
  }

  WEEK_DATE_FORMAT = '%d/%m/%Y'

  def <(other_week)
    year < other_week.year || (year == other_week.year && number < other_week.number)
  end

  def in_the_passed?
    self < Week.current
  end

  def self.current
    current_date = Date.today
    Week.find_by(number: current_date.cweek, year: current_date.year)
  end
  
  def self.fetch_by_date(date:)
    Week.find_by(number: date.cweek, year: date.year)
  end

  def self.next
    date = Date.today + 1.week
   fetch_by_date(date: date)
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

  # This method is not used .... keep ?
  def self.airtablize(school_year = SchoolYear::Current.new)
    school_year_str = "#{school_year.beginning_of_period.year}-#{school_year.end_of_period.year}"
    weeks = Week.selectable_for_school_year(school_year: school_year)

    require 'csv'
    CSV.open("myfile.csv", "w") do |csv|
      csv << ["Semaine", "ID MS3e", "year"]
      weeks.map do |w|
        csv << [w.select_text_method, w.id, school_year_str]
      end
    end
  end
end
