# frozen_string_literal: true

require 'test_helper'
module Users
  class StudentTest < ActiveSupport::TestCase
    test 'Student should not be able to authenticate if parental consent was not received by teacher' do
      student = create(:student, has_parental_consent: false)

      refute student.active_for_authentication?

      student.update(has_parental_consent: true)
      assert student.active_for_authentication?
    end

    test 'student.after_sign_in_path redirects to internship_offers_path' do
      student = create(:student)
      assert_equal(student.after_sign_in_path,
                   Rails.application
                        .routes
                        .url_helpers
                        .dashboard_students_internship_applications_path(student_id: student.id))
    end

    test 'student.missing_school_week' do
      school = create(:school)
      student = create(:student, school: school)
      student.missing_school_weeks = school
      assert_changes -> { school.reload.missing_school_weeks_count },
                     from: 0,
                     to: 1 do
        student.save!
      end
      assert_equal [student], school.students_with_missing_school_week
    end
  end
end
