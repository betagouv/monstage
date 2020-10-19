# frozen_string_literal: true

module Reporting
  # wrap reporting for School
  class School < ApplicationRecord
    include FindableWeek

    def readonly?
      true
    end
    PAGE_SIZE = 100

    has_many :users, foreign_type: 'type'
    has_many :students, class_name: 'Users::Student'

    has_many :school_managements, dependent: :nullify,
                                  class_name: 'Users::SchoolManagement'

    has_many :main_teachers, -> { where(role: :main_teacher) },
             class_name: 'Users::SchoolManagement'
    has_many :teachers, -> { where(role: :teacher) },
             class_name: 'Users::SchoolManagement'
    has_many :others, -> { where(role: :other) },
             class_name: 'Users::SchoolManagement'
    has_one :school_manager, -> { where(role: :school_manager) },
            class_name: 'Users::SchoolManagement'

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

    scope :without_school_manager, lambda {
      left_joins(:school_manager)
        .group('schools.id')
        .having('count(users.id) = 0')
    }
    # maybe useless
    scope :in_the_future, lambda {
      more_recent_than(week: ::Week.current)
    }

    scope :with_school_track, lambda { |school_track|
      joins(:class_rooms)
        .where('class_rooms.school_track = ?', school_track)
    }

    paginates_per PAGE_SIZE

    def students
      users.select { |user| user.is_a?(Users::Student) }
    end

    def total_student_count
      students.size
    end

    def total_student_with_confirmation_count
      students.select(&:confirmed_at?)
              .size
    end

    def total_student_confirmed
      students.select(&:confirmed?)
              .size
    end

    def total_student_count
      students.size
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

    def total_approved_internship_applications_count
      internship_applications.approved.size
    end
  end
end
