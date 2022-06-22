require 'test_helper'

module Dashboard::InternshipAgreements::Users
  class ResendSmsCodeControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'when employer request for a sms code resend succeeds' do
      assert_enqueued_jobs 1, only: SendSmsJob do
        internship_agreement = create(:troisieme_generale_internship_agreement)
        employer = internship_agreement.employer
        employer.update(phone: '+330602030405')
        sign_in(employer)

        post resend_sms_code_dashboard_internship_agreement_user_path(
                internship_agreement_id: internship_agreement.id,
                format: :turbo_stream,
                id: employer.id),
            params: {}

        assert_select '#code-request', text: 'Un nouveau code a été envoyé'
      end
    end

    test 'when employer requests for a sms code resend fails' do
      internship_agreement = create(:troisieme_generale_internship_agreement)
      employer = internship_agreement.employer
      assert_enqueued_jobs 0, only: SendSmsJob do
        sign_in(employer)

        post resend_sms_code_dashboard_internship_agreement_user_path(
                internship_agreement_id: internship_agreement.id,
                id: employer.id),
            params: {}

        # assert_redirected_to dashboard_internship_agreements_path
      end
      assert 422, response.status
    end

    test 'school manager requests for a sms code resend succeeds' do
      assert_enqueued_jobs 1, only: SendSmsJob do
        internship_agreement = create(:troisieme_generale_internship_agreement)
        school_manager = internship_agreement.student.school.school_manager
        school_manager.update(phone: '+330602030405')
        sign_in(school_manager)

        post resend_sms_code_dashboard_internship_agreement_user_path(
                internship_agreement_id: internship_agreement.id,
                format: :turbo_stream,
                id: school_manager.id),
            params: {}

        assert_select '#code-request', text: 'Un nouveau code a été envoyé'
      end
    end

    test 'when school manager requests for a sms code resend fails' do
      internship_agreement = create(:troisieme_generale_internship_agreement)
      school_manager = internship_agreement.student.school.school_manager
      assert_enqueued_jobs 0, only: SendSmsJob do
        sign_in(school_manager)

        post resend_sms_code_dashboard_internship_agreement_user_path(
                internship_agreement_id: internship_agreement.id,
                id: school_manager.id),
            params: {}

      end
      assert 422, response.status
    end
  end
end
