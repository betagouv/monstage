# frozen_string_literal: true

module Reporting
  # wrap reporting for School
  class School < ApplicationRecord
    has_many :users, foreign_type: 'type'

    PAGE_SIZE = 30
    paginates_per PAGE_SIZE

    def readonly?
      true
    end

    def students
      users.select{|user| user.is_a?(Users::Student)}
    end

    def total_student_count
      students.size
    end

    def total_student_with_confirmation_count
      students.select{|user| user.confirmed_at?}
              .size
    end

    def total_student_with_parental_consent_count
      students.select{|user| user.has_parental_consent? }
              .size
    end

    def school_manager?
      users.select{|user| user.is_a?(Users::SchoolManager)}
           .size
           .positive?
    end

    def total_main_teacher_count
      users.select{|user| user.is_a?(Users::MainTeacher)}
           .size
    end
  end
end
