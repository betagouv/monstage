# frozen_string_literal: true

module FindableWeek
  extend ActiveSupport::Concern

  included do
    scope :by_weeks, lambda { |weeks:|
      joins(:weeks).where(weeks: { id: weeks.ids })
    }

    # p 'called également par api ? by weeks'
    # p 'self.class'
    # p self.class
    # p 'before joins'
    # # byebug
    # p 'weeks'
    # p weeks
    # joins(:weeks).where(weeks: weeks)

    scope :older_than, lambda { |week:|
      joins(:weeks).where('weeks.year < :year OR (weeks.year = :year AND weeks.number >= :number)',
                          year: week.year, number: week.number)
    }

    scope :in_the_past, lambda {
      where('last_date < ?', Date.today)
    }

    scope :in_the_future, lambda {
      where('last_date > ?', Date.today)
    }

    scope :more_recent_than, lambda { |week:|
      joins(:weeks).where('weeks.year > :year OR (weeks.year = :year AND weeks.number >= :number)',
                          year: week.year, number: week.number)
    }
  end
end
