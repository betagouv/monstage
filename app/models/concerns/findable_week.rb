# frozen_string_literal: true

module FindableWeek
  extend ActiveSupport::Concern

  included do
    scope :by_weeks, lambda { |weeks:|
      joins(:weeks).where(weeks: { id: weeks.ids })
    }

    scope :older_than, lambda { |week:|
      joins(:weeks).where('weeks.year > ? OR (weeks.year = ? AND weeks.number >= ?)', week.year, week.year, week.number)
    }

    scope :available_in_the_future, lambda {
      older_than(week: Week.current)
    }
  end
end
