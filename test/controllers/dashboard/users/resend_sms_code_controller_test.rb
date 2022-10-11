require 'test_helper'

module Dashboard::Users
  class ResendSmsCodeControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'when employer request for a sms code resend succeeds' do
      internship_agreement = create(:internship_agreement)
      assert_enqueued_jobs 1, only: SendSmsJob do
        employer = internship_agreement.employer
        employer.update(phone: '+330602030405')
        sign_in(employer)

        post  resend_sms_code_dashboard_user_path(
                format: :turbo_stream,
                id: employer.id),
              params: {user: {id: employer.id}}

      end
      assert_response :success
      assert_select "#code-request", text: 'Un nouveau code a été envoyé'
    end

    test 'when employer requests for a sms code resend fails' do
      internship_agreement = create(:internship_agreement)
      employer = internship_agreement.employer
      assert_enqueued_jobs 0, only: SendSmsJob do
        sign_in(employer)
        raises_exception = -> { raise ArgumentError.new }

        Users::Employer.stub_any_instance(:send_signature_sms_token, raises_exception) do
          post resend_sms_code_dashboard_user_path(
                  format: :turbo_stream,
                  id: employer), # student is not allowed to resend sms code
              params: {user: {id: employer.id}}

        end
      end
      assert_response :success
      assert_select "#code-request", text: "Une erreur est survenue et votre demande n'a pas été traitée"
    end

    test 'school manager requests for a sms code resend succeeds' do
      internship_agreement = create(:internship_agreement)
      school_manager = internship_agreement.school_manager
      school_manager.update(phone: '+330602030405')
      sign_in(school_manager)
      assert_enqueued_jobs 1, only: SendSmsJob do

        post resend_sms_code_dashboard_user_path(
                format: :turbo_stream,
                id: school_manager.id),
            params: {user: {id: school_manager.id}}
        assert_response :success
        assert_select "#code-request", text: 'Un nouveau code a été envoyé'
      end
    end

    test 'when school manager requests for a sms code resend fails' do
      internship_agreement = create(:internship_agreement)
      school_manager = internship_agreement.school_manager
      raises_exception = -> { raise ArgumentError.new }
      assert_enqueued_jobs 0, only: SendSmsJob do
        sign_in(school_manager)
        Users::SchoolManagement.stub_any_instance(:send_signature_sms_token, raises_exception) do
          post resend_sms_code_dashboard_user_path(
                  format: :turbo_stream,
                  id: create(:student).id), # student is not allowed to resend sms code
              params: {user: {id: school_manager.id}}

        end
      end
      assert_response :success
      assert_select "#code-request", text: "Une erreur est survenue et votre demande n'a pas été traitée"
    end
  end
end
