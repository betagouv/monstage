require 'application_system_test_case'
module Dashboard::Users
  class RequestPhoneNumberTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers
    include TeamAndAreasHelper

    test 'employer without phone number starts the signing process' do
      # see signature_test.rb
    end

    test 'employer with phone number starts the signing process' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, internship_application: internship_application, aasm_state: :validated)
      employer.update(phone: '+330622554411')
      sign_in(employer)

      visit dashboard_internship_agreements_path
      click_on 'Ajouter aux signatures'
      find('button.fr-btn.button-component-cta-button[disabled]')
      click_on 'Signer'

      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
    end

    test 'school_manager with phone number starts the signing process' do
      internship_agreement = create(:internship_agreement, :validated)
      school_manager = internship_agreement.school_manager
      school_manager.update(phone: '+330622554411')
      sign_in(school_manager.reload)

      visit dashboard_internship_agreements_path
      click_on 'Ajouter aux signatures'
      click_on 'Signer'

      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
    end
  end
end
