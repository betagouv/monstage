# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    test 'PATCH #update with approve! transition sends email' do
      internship_application = create(:internship_application, :submitted)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 1 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :approve! })
        assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end
      assert InternshipApplication.last.approved?
    end

    test 'PATCH #update with reject! transition sends email' do
      internship_application = create(:internship_application, :submitted)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 1 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :reject! })
        assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end

      assert InternshipApplication.last.rejected?
    end

    test 'PATCH #update with cancel! does not send email, change aasm_state' do
      internship_application = create(:internship_application, :approved)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 0 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :cancel! })
        assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end
      internship_application.reload

      assert internship_application.rejected?
    end

    test 'PATCH #update as employer with signed! does not send email, change aasm_state' do
      internship_application = create(:internship_application, :approved)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 0 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :signed! })
        assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end
      internship_application.reload
      assert internship_application.convention_signed?
    end

    test 'PATCH #update as school manager works' do
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)
      internship_application = create(:internship_application, :approved, student: student)

      sign_in(school.school_manager)

      assert_enqueued_emails 0 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :signed! })
        assert_redirected_to school.school_manager.after_sign_in_path
      end
      internship_application.reload
      assert internship_application.convention_signed?
    end
  end
end
