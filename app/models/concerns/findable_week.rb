# frozen_string_literal: true

module FindableWeek
  extend ActiveSupport::Concern

  included do
    scope :by_weeks, lambda { |weeks:|
      joins(:weeks).where(weeks: { id: weeks.ids })
    }

    scope :older_than, lambda { |week:|
      joins(:weeks).where('weeks.year < :year OR (weeks.year = :year AND weeks.number >= :number)',
                          year: week.year, number: week.number)
    }
    # maybe useless
    scope :in_the_past, lambda {
      where('last_date < ?', Date.today)
    }

    scope :more_recent_than, lambda { |week:|
      joins(:weeks).where('weeks.year > :year OR (weeks.year = :year AND weeks.number >= :number)',
                          year: week.year, number: week.number)
    }
  end
end
