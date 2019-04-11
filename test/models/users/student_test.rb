require 'test_helper'
module Users
  class StudentTest < ActiveSupport::TestCase

    test 'Student should not be able to authenticate if parental consent was not received by teacher' do
      student = create(:student, has_parental_consent: false)

      refute student.active_for_authentication?

      student.update(has_parental_consent: true)
      assert student.active_for_authentication?
    end

    test 'employer.after_sign_in_path redirects to internship_offers_path' do
      student = build(:student)
      assert_equal(student.after_sign_in_path,
                   Rails.application.routes.url_helpers.internship_offers_path)
    end
  end
end
