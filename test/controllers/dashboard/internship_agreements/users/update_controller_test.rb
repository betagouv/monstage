require 'test_helper'

module Dashboard::InternshipAgreements::Users
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'employer updates his account with a phone number with ok params' do
      internship_agreement = create(:internship_agreement)
      employer = internship_agreement.employer
      sign_in(employer)

      params = {
        user: {
          phone: '+330602030405',
          internship_agreement_id: internship_agreement.id,
          user_id: employer.id
        }
      }
      assert_enqueued_jobs 1, only: SendSmsJob do
        patch dashboard_internship_agreement_user_path(
                format: :turbo_stream,
                internship_agreement_id: internship_agreement.id,
                id: employer.id),
              params: params
      end

      assert_response :success
      assert_select '.test-phone-signature', text: employer.obfuscated_phone_number
    end

    test 'school_manager updates his account with a phone number with ok params' do
      internship_agreement = create(:internship_agreement)
      school_manager = internship_agreement.school_manager
      sign_in(school_manager)

      params = {
        user: {
          phone: '+330602030405',
          internship_agreement_id: internship_agreement.id,
          user_id: school_manager.id
        }
      }
      assert_enqueued_jobs 1, only: SendSmsJob do
        patch dashboard_internship_agreement_user_path(
                format: :turbo_stream,
                internship_agreement_id: internship_agreement.id,
                id: school_manager.id),
              params: params
      end

      assert_response :success
      assert_select '.test-phone-signature', text: school_manager.obfuscated_phone_number
    end

    test 'employer updates his account with a phone number with bad params' do
      internship_agreement = create(:internship_agreement)
      employer = internship_agreement.employer
      sign_in(employer)

      params = {
        user: {
          phone: '+33060405', # bad phone number
          internship_agreement_id: internship_agreement.id,
          user_id: employer.id
        }
      }
      patch dashboard_internship_agreement_user_path(
              format: :turbo_stream,
              internship_agreement_id: internship_agreement.id,
              id: employer.id),
            params: params

      assert_redirected_to dashboard_internship_agreements_path
      follow_redirect!
      assert_response :success
      assert_select '#alert-text', text: "Une erreur est survenue et le SMS n'a pas été envoyé"
    end
  end
end
