# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'patch #update works for student owning internship_application, ' \
         'with transition=submit! submit internship_application and redirect to dashboard/students/internship_application#show' do
      internship_offer = create(:weekly_internship_offer)
      internship_application = create(:weekly_internship_application, :drafted, internship_offer: internship_offer)
      sign_in(internship_application.student)
      assert_changes -> { internship_application.reload.submitted? },
                     from: false,
                     to: true do
        patch internship_offer_internship_application_path(internship_offer,
                                                           uuid: internship_application.uuid,
                                                           transition: :submit!)
        assert_redirected_to dashboard_students_internship_applications_path(
          internship_application.student,
          notice_banner: true
        )
      end
    end

    test 'patch #update works for student owning internship_application, ' \
         'without transition=submit! updates internship_applications and redirect to show' do
      internship_offer = create(:weekly_internship_offer)
      initial_motivation = 'pizza'
      new_motivation = 'le travail dequipe'
      internship_application = create(:weekly_internship_application, :drafted, internship_offer: internship_offer,
                                                                                motivation: initial_motivation)
      sign_in(internship_application.student)
      assert_changes -> { internship_application.reload.motivation.to_plain_text },
                     from: initial_motivation,
                     to: new_motivation do
        patch internship_offer_internship_application_path(internship_offer,
                                                           uuid: internship_application.uuid),
              params: { internship_application: { motivation: new_motivation } }
        assert_redirected_to internship_offer_internship_application_path(internship_offer,
          uuid: internship_application.uuid)
      end
    end

    test 'patch #update from submit to submit fails gracefully' do
      internship_application = create(:weekly_internship_application, :submitted)
      sign_in(internship_application.student)
      patch internship_offer_internship_application_path(internship_application.internship_offer,
                                                         uuid: internship_application.uuid,
                                                         transition: :submit!)
      assert_redirected_to dashboard_students_internship_applications_path(internship_application.student,
                                                                           uuid: internship_application.uuid)
    end

    test 'patch #update for student not owning internship_application is forbidden' do
      internship_offer = create(:weekly_internship_offer)
      internship_application = create(:weekly_internship_application, :drafted, internship_offer: internship_offer)
      sign_in(create(:student))

      patch internship_offer_internship_application_path(internship_offer,
                                                         uuid: internship_application.uuid,
                                                         transition: :submit!),
            params: { internship_application: { motivation: 'whoop' } }
      assert_response :redirect
    end
  end
end
