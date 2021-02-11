# frozen_string_literal: true

# Calendar weeks
class Week < ApplicationRecord
  include FormatableWeek
  has_many :internship_offer_weeks, dependent: :destroy,
                                    foreign_key: :week_id
  has_many :internship_applications, through: :internship_offer_weeks

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

  scope :weeks_of_school_year, lambda { |school_year:|
    first_week_of_september = Date.new(school_year, 9, 1).cweek
    last_day_of_may_week    = Date.new(school_year + 1, 5, 31).cweek

    where('number >= ?', first_week_of_september).where( year: school_year)
     .or(where('number <= ?', last_day_of_may_week).where( year: school_year + 1))
  }

  WEEK_DATE_FORMAT = '%d/%m/%Y'

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

  # used to check if a week has any ongoing internship_application (so we avoid unlinking an offer/school and create orphan data)
  def has_applications?(root:)
    if root.is_a?(InternshipOffer)
      internship_applications.where(internship_offer_weeks: { week_id: self.id, internship_offer_id: root.id })
                             .count
                             .positive?
    elsif root.is_a?(School)
      internship_applications.where(student: root.students)
                             .count
                             .positive?
    elsif root.is_a?(InternshipOfferInfo) || root.is_a?(SupportTicket)
      return false
    else

      raise ArgumentError "unknown root: #{root}, selectable week only works with school/internship_offer"
    end
  end

  def consecutive_to?(other_week)
    (self.year == other_week.year && self.number == other_week.number + 1) ||
    (self.year == other_week.year + 1 && self.number == 1 && other_week.number == last_week_of_civil_year(year: other_week.year).number)
  end

  def last_week_of_civil_year(year: )
     Week.by_year(year: year).order(number: :asc).last
  end

end
