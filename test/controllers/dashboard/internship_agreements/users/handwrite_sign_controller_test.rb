require 'test_helper'

module Dashboard::InternshipAgreements::Users
  class HandwriteSignControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def check_code(user)
      user.update(signature_phone_token_checked_at: DateTime.now)
    end

    test 'employer handwrite_sign_dashboard_internship_agreement_user_path with success' do
      if ENV['RUN_BRITTLE_TEST']
        internship_agreement = create(:internship_agreement, aasm_state: :validated)
        employer = internship_agreement.employer
        employer.update(phone: '+330623456789')
        employer.create_signature_phone_token
        check_code(employer)
        sign_in(employer)

        params = {
          user:{
            id: employer.id,
            internship_agreement_id: internship_agreement.id,
            signature_image: File.read(Rails.root.join(*%w[test fixtures files signature]))
          }
        }

        post handwrite_sign_dashboard_internship_agreement_user_path(
              internship_agreement_id: internship_agreement.id,
              id: employer.id), params: params
        follow_redirect!
        assert_response :success
        assert_equal 'Votre signature a été enregistrée', flash[:notice]
        assert_equal 1, Signature.count
      end
    end

    test 'when employer handwrite_sign_dashboard_internship_agreement_user_path fails with missing handwrite' do
      internship_agreement = create(:internship_agreement, aasm_state: :validated)
      employer = internship_agreement.employer
      employer.update(phone: '+330623456789')
      employer.create_signature_phone_token
      check_code(employer)
      sign_in(employer)

      params = {
        user:{
          id: employer.id,
          internship_agreement_id: internship_agreement.id
        } # no handwrite_signature
      }

      post handwrite_sign_dashboard_internship_agreement_user_path(
            internship_agreement_id: internship_agreement.id,
            id: employer.id), params: params
      follow_redirect!
      assert_response :success
      assert_equal 'Votre signature n\'a pas été détectée', flash[:alert]
      assert_equal 0, Signature.count
    end

    test 'when employer handwrite_sign_dashboard_internship_agreement_user_path fails with unchecked token' do
      if ENV['RUN_BRITTLE_TEST']
        internship_agreement = create(:internship_agreement, aasm_state: :validated)
        employer = internship_agreement.employer
        employer.update(phone: '+330623456789')
        employer.create_signature_phone_token
        # no check_code
        sign_in(employer)

        params = {
          user:{
            id: employer.id,
            internship_agreement_id: internship_agreement.id,
            signature_image: File.read(Rails.root.join(*%w[test fixtures files signature]))
          }
        }

        post handwrite_sign_dashboard_internship_agreement_user_path(
              internship_agreement_id: internship_agreement.id,
              id: employer.id), params: params
        follow_redirect!
        assert_response :success
        assert_equal 'Votre signature n\'a pas été enregistrée', flash[:alert]
        assert_equal 0, Signature.count
      end
    end
  end
end
