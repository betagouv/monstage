# frozen_string_literal: true

require 'test_helper'
module Users
  class StudentTest < ActiveSupport::TestCase
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

    test 'validate wrong mobile phone format' do
      user = build(:student, phone: '0111223344')
      refute user.valid?
      assert_equal ["Numéro de téléphone invalide"], user.errors.messages[:phone]
    end

    test 'validate wrong phone format' do
      user = build(:student, phone: '0612')
      refute user.valid?
      assert_equal ["Numéro de téléphone invalide"], user.errors.messages[:phone]
    end

    test 'validate good phone format' do
      user = build(:student, phone: '0611223344')
      assert user.valid?
    end

    test 'no phone token creation after user creation' do
      user = create(:student, phone: '')
      assert_nil user.phone_token
      assert_nil user.phone_token_validity
    end

    test 'phone token creation after user creation' do
      user = create(:student, phone: '0711223344')
      assert_not_nil user.phone_token
      assert_equal 4, user.phone_token.size
      assert_not_nil user.phone_token_validity
      assert_equal true, user.phone_token_validity.between?(59.minutes.from_now, 61.minutes.from_now)
    end
  end
end