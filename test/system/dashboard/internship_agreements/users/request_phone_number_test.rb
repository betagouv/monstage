require 'application_system_test_case'
module Dashboard::InternshipAgreements::Users
  class RequestPhoneNumberTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'employer without phone number starts the signing process' do
      # see signature_test.rb
    end

    test 'employer with phone number starts the signing process' do
      internship_agreement = create(:troisieme_generale_internship_agreement, :validated)
      employer = internship_agreement.employer
      employer.update(phone: '+330622554411')
      sign_in(employer.reload)

      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'

      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
    end

    test 'school_manager with phone number starts the signing process' do
      internship_agreement = create(:troisieme_generale_internship_agreement, :validated)
      school_manager = internship_agreement.school_manager
      school_manager.update(phone: '+330622554411')
      sign_in(school_manager.reload)

      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'

      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
    end
  end
end
