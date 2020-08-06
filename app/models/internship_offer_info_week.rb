class InternshipOfferInfoWeek < ApplicationRecord
  belongs_to :internship_offer_info, counter_cache: true # ,
  # inverse_of: :internship_offer_weeks
  belongs_to :week

  # has_many :internship_applications, dependent: :destroy

  delegate :select_text_method, :human_select_text_method, to: :week
  delegate :max_candidates, to: :internship_offer_info

  scope :ignore_max_candidates_reached, lambda { |max_candidates:|
    where('blocked_applications_count < :max_candidates', max_candidates: max_candidates)
  }

  scope :by_weeks, lambda { |weeks:|
    where(week: weeks)
  }

  scope :after_week, lambda { |week:|
    joins(:week).where('weeks.year > ? OR (weeks.year = ? AND weeks.number > ?)', week.year, week.year, week.number)
  }

  scope :after_current_week, lambda {
    after_week(week: Week.current)
  }

  scope :applicable, lambda { |user:, internship_offer:|
    by_weeks(weeks: user.school.weeks)
      .ignore_max_candidates_reached(max_candidates: internship_offer.max_candidates)
      .after_current_week
      .includes(:week)
  }

  def has_spots_left?
    blocked_applications_count < max_candidates
  end
end
