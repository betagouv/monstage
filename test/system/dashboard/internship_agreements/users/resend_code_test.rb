require 'application_system_test_case'
module Dashboard::InternshipAgreements::Users
  class ResendCodeTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'employer requests a new code and everything is ok' do
      internship_agreement = create(:troisieme_generale_internship_agreement, :validated)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'

      find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer la convention de stage')
      find('input#phone-input').set('0612345678')
      click_button('Recevoir un code')

      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
      find('button.fr-btn[disabled]')
      click_link('Renvoyer le code')
      sleep 0.1
      find('#code-request', text: 'Un nouveau code a été envoyé')
    end

    test 'school_manager requests a new code and everything is ok' do
      internship_agreement = create(:troisieme_generale_internship_agreement, :validated)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'

      find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer la convention de stage')
      find('input#phone-input').set('0612345678')
      click_button('Recevoir un code')

      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
      find('button.fr-btn[disabled]')
      click_link('Renvoyer le code')
      sleep 0.1
      find('#code-request', text: 'Un nouveau code a été envoyé')
    end

    test 'employer requests a new code and it fails for almost no reason' do
      internship_agreement = create(:troisieme_generale_internship_agreement, :validated)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'

      find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer la convention de stage')
      find('input#phone-input').set('0612345678')
      click_button('Recevoir un code')
      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')

      Users::Employer.stub_any_instance(:school_management?, true) do #error
        click_link('Renvoyer le code')
        find('span#alert-text',
             text: "Une erreur est survenue et votre demande n'a pas été traitée")
      end
    end
  end
end
