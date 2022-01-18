# frozen_string_literal: true

module Weekable
  extend ActiveSupport::Concern

  included do
    belongs_to :week

    delegate :select_text_method, :human_select_text_method, to: :week

    # TODO : rename
    scope :ignore_max_candidates_reached, lambda { |max_students_per_group:|
      where('blocked_applications_count < :max_students_per_group', max_students_per_group: max_students_per_group)
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

    def has_spots_left?
      blocked_applications_count < max_students_per_group
    end
  end
end
