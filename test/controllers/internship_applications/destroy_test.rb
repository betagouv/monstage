# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class DestroyTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    test 'DELETE #destroy internship application as student fails' do
      school = create(:school, :with_school_manager)
      school_manager = school.school_manager
      student = create(:student, school: school)
      internship_application = create(:internship_application, student: student)
      sign_in(student)
      sign_in(student)
      delete internship_offer_internship_application_path(internship_application.internship_offer,
                                                          internship_application)
      assert_redirected_to root_path
    end

    test 'DELETE #destroy internship application as school manager works' do
      school = create(:school, :with_school_manager)
      school_manager = school.school_manager
      student = create(:student, school: school)
      internship_application = create(:internship_application, student: student)
      sign_in(school_manager)

      assert_difference('InternshipApplication.count', -1) do
        delete internship_offer_internship_application_path(internship_application.internship_offer,
                                                            internship_application)
        assert_redirected_to internship_offer_path(internship_application.internship_offer, anchor: 'internship-application-form')
      end
    end
  end
end
