# frozen_string_literal: true

module Reporting
  # wrap reporting for School
  class School < ApplicationRecord
    include FindableWeek
    include SchoolUsersAssociations

    def readonly?
      true
    end
    PAGE_SIZE = 100

    has_many :school_internship_weeks
    has_many :weeks, through: :school_internship_weeks
    has_many :class_rooms

    has_many :internship_applications, through: :students do
      def approved
        where(aasm_state: :approved)
      end
    end

    scope :count_with_school_manager, lambda {
      joins(:school_manager)
        .distinct('schools.id')
        .count
    }

    scope :with_school_manager, lambda {
      left_joins(:school_manager)
        .group('schools.id')
    }

    scope :without_school_manager, lambda {
      where.missing(:school_manager)
    }

    scope :with_manager_simply, lambda { joins(:school_manager) }

    scope :in_the_future, lambda {
      more_recent_than(week: ::Week.current)
    }

    scope :with_school_track, lambda { |school_track|
      joins(:class_rooms)
        .where('class_rooms.school_track = ?', school_track)
    }

    scope :by_subscribed_school, ->(subscribed_school:)  {
      case subscribed_school.to_s
      when 'true'
        with_manager_simply
      when 'false'
        without_school_manager
      else
        all
      end
    }

    paginates_per PAGE_SIZE

    def total_student_count
      students_not_anonymized.size
    end

    def total_student_with_confirmation_count
      students_not_anonymized.select(&:confirmed_at?)
              .size
    end

    def total_student_confirmed
      students_not_anonymized.select(&:confirmed?)
              .size
    end

    def total_student_count
      students_not_anonymized.size
    end

    def school_manager?
      users.select { |user| user.school_manager? }
           .size
           .positive?
    end

    def total_main_teacher_count
      users.select { |user| user.main_teacher? }
           .size
    end

    def total_approved_internship_applications_count(school_year:)
      query = internship_applications.approved
      query = query.where("internship_applications.created_at >= ?", SchoolYear::Floating.new_by_year(year: school_year.to_i).beginning_of_period) if school_year
      query = query.where("internship_applications.created_at <= ?", SchoolYear::Floating.new_by_year(year: school_year.to_i).end_of_period) if school_year
      query.size
    end

    private
    def students_not_anonymized
      users.select(&:student?)
           .reject(&:anonymized)
    end
  end
end
