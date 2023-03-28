# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'patch #update works for student owning internship_application, ' \
         'with transition=submit! submit internship_application and redirect to dashboard/students/internship_application#show' do
      internship_offer = create(:internship_offer)
      internship_application = create(:weekly_internship_application, :drafted, internship_offer: internship_offer)
      sign_in(internship_application.student)
      assert_changes -> { internship_application.reload.submitted? },
                     from: false,
                     to: true do
        patch internship_offer_internship_application_path(internship_offer,
                                                           internship_application,
                                                           transition: :submit!)
        assert_redirected_to completed_internship_offer_internship_application_path(internship_offer,
                                                                             internship_application)
      end
    end

    test 'patch #update works for main_teacher owning internship_application, ' \
         'with transition=submit! submit internship_application and redirect to dashboard/students/internship_application#show' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, class_room: class_room, school: school)
      main_teacher = create(:main_teacher, class_room: class_room, school: school)
      internship_offer = create(:internship_offer, school: school)
      internship_application = create(:weekly_internship_application, :drafted, internship_offer: internship_offer, student: student)
      sign_in(main_teacher)
      assert_changes -> { internship_application.reload.submitted? },
                     from: false,
                     to: true do
        patch internship_offer_internship_application_path(internship_offer,
                                                           internship_application,
                                                           transition: :submit!)
        assert_redirected_to completed_internship_offer_internship_application_path(internship_offer,
                                                                             internship_application)
      end
    end

    test 'patch #update works for student owning internship_application, ' \
         'without transition=submit! updates internship_applications and redirect to show' do
      internship_offer = create(:internship_offer)
      initial_motivation = 'pizza biere'
      new_motivation = 'le travail dequipe'
      internship_application = create(:weekly_internship_application, :drafted, internship_offer: internship_offer,
                                                                                motivation: initial_motivation)
      sign_in(internship_application.student)
      assert_changes -> { internship_application.reload.motivation.to_plain_text },
                     from: initial_motivation,
                     to: new_motivation do
        patch internship_offer_internship_application_path(internship_offer,
                                                           internship_application),
              params: { internship_application: { motivation: new_motivation } }
        assert_redirected_to internship_offer_internship_application_path(internship_offer,
                                                                          internship_application)
      end
    end

    test 'patch #update from submit to submit fails gracefully' do
      internship_application = create(:weekly_internship_application, :submitted)
      sign_in(internship_application.student)
      patch internship_offer_internship_application_path(internship_application.internship_offer,
                                                         internship_application,
                                                         transition: :submit!)
      assert_redirected_to dashboard_students_internship_applications_path(internship_application.student,
                                                                           internship_application)
    end

    test 'patch #update for student not owning internship_application is forbidden' do
      internship_offer = create(:internship_offer)
      internship_application = create(:weekly_internship_application, :drafted, internship_offer: internship_offer)
      sign_in(create(:student))

      patch internship_offer_internship_application_path(internship_offer,
                                                         internship_application,
                                                         transition: :submit!),
            params: { internship_application: { motivation: 'whoop' } }
      assert_response :redirect
    end
  end
end
