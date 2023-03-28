# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #show renders weekly_internship_application preview for student owning internship_application' do
      internship_offer = create(:internship_offer)
      internship_application = create(:weekly_internship_application, :drafted, internship_offer: internship_offer)
      sign_in(internship_application.student)
      get internship_offer_internship_application_path(internship_offer,
                                                       internship_application)
      assert_response :success
      assert_select 'title', 'Ma candidature | Monstage'

      assert_select "form[action=\"#{internship_offer_internship_application_path(internship_offer, internship_application, transition: :submit!)}\"]"
      assert_select "#submit_application_form[method='post'] input[name='_method'][value='patch']"
      assert_select '.student-email', internship_application.student_email
      assert_select '.student-phone', internship_application.student_phone
    end

    test 'GET #show renders preview for school_manager' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, class_room: class_room, school: school)
      main_teacher = create(:main_teacher, class_room: class_room, school: school)
      internship_offer = create(:internship_offer, school: school)
      internship_application = create(:weekly_internship_application, :drafted, internship_offer: internship_offer, student: student)
      sign_in(main_teacher)
      get internship_offer_internship_application_path(internship_offer,
                                                       internship_application)
      assert_response :success
      assert_select "form[action=\"#{internship_offer_internship_application_path(internship_offer, internship_application, transition: :submit!)}\"]"
      assert_select "#submit_application_form[method='post'] input[name='_method'][value='patch']"
    end

    test 'GET #show not owning internship_application is forbidden' do
      internship_offer = create(:internship_offer)
      internship_application = create(:weekly_internship_application, :drafted, internship_offer: internship_offer)
      sign_in(create(:student))
      get internship_offer_internship_application_path(internship_offer,
                                                       internship_application)
      assert_response :redirect
    end
  end
end
