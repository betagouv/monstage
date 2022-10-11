require 'test_helper'

module Dashboard::Users
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'employer updates his account with a phone number with ok params' do
      internship_agreement = create(:internship_agreement)
      employer = internship_agreement.employer
      sign_in(employer)

      params = {
        user: {
          phone_prefix: '+33',
          phone_suffix: '0602030405',
          user_id: employer.id
        }
      }
      assert_enqueued_jobs 1, only: SendSmsJob do
        patch dashboard_user_path( format: :turbo_stream, id: employer.id),
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
          phone_prefix: '+33',
          phone_suffix: '0602030405',
          user_id: school_manager.id
        }
      }
      assert_enqueued_jobs 1, only: SendSmsJob do
        patch dashboard_user_path( format: :turbo_stream, id: school_manager.id),
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
          phone_prefix: '+33',
          phone_suffix: '0600405', # bad phone number
          internship_agreement_id: internship_agreement.id,
          user_id: employer.id
        }
      }
      patch dashboard_user_path( format: :turbo_stream, id: employer.id),
            params: params

      assert_response :success
      assert_select '.fr-alert p', text: "Veuillez modifier le numéro de téléphone mobile"
    end
  end
end
