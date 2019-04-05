require 'test_helper'

module InternshipApplications
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    test "PATCH #update with approve! transition sends email" do
      internship_application = create(:internship_application)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 1 do
        patch(internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :approve! })
      end

      assert_redirected_to internship_offer_internship_applications_path(internship_application.internship_offer)

      assert InternshipApplication.last.approved?
    end

    test "PATCH #update with reject! transition sends email" do
      internship_application = create(:internship_application)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 1 do
        patch(internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :reject! })
      end

      assert_redirected_to internship_offer_internship_applications_path(internship_application.internship_offer)

      assert InternshipApplication.last.rejected?
    end

    test "PATCH #update with cancel! does not send email, change aasm_state" do
      internship_application = create(:internship_application, aasm_state: :approved)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 0 do
        patch(internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :cancel! })
      end
      internship_application.reload

      assert internship_application.rejected?
      assert_redirected_to internship_offer_internship_applications_path(internship_application.internship_offer)
    end

    test "PATCH #update with signed! does not send email, change aasm_state" do
      internship_application = create(:internship_application, aasm_state: :approved)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 0 do
        patch(internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :signed! })
      end
      internship_application.reload
      assert internship_application.convention_signed?
      assert_redirected_to internship_offer_internship_applications_path(internship_application.internship_offer)
    end
  end
end
