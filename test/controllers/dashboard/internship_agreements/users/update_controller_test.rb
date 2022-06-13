require 'test_helper'

module Dashboard::InternshipAgreements::Users
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'employer updates his account with a phone number with ok params' do
      internship_agreement = create(:troisieme_generale_internship_agreement)
      sign_in(internship_agreement.employer)

      params = {
        user: {
          phone: '+330602030405',
          internship_agreement_id: internship_agreement.id,
          current_user: internship_agreement.employer.id
        }
      }

      patch dashboard_internship_agreement_user_path(
        internship_agreement_id: internship_agreement.id,
        id: internship_agreement.employer.id,
        params: params)

      assert_redirected_to :success




    end
  end
end
