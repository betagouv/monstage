require 'application_system_test_case'
module Dashboard::InternshipAgreements::Users
  class SignatureTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    def code_script_enables(index)
      "document.getElementById('user-code-#{index}').disabled=false"
    end
    def code_script_assign(signature_phone_tokens, index)
      "document.getElementById('user-code-#{index}').value=#{signature_phone_tokens[index]}"
    end


    test 'employer signs and everything is ok' do
      internship_agreement = create(:troisieme_generale_internship_agreement, :validated)
      employer = internship_agreement.employer
      sign_in(employer)

      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'

      find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer la convention de stage')
      find('input#phone-input').set('0612345678')
      click_button('Recevoir un code')

      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
      find('button.fr-btn[disabled]')
      signature_phone_tokens = employer.reload.signature_phone_token.split('')
      (0..5).to_a.each do |index|
        execute_script(code_script_enables(index))
        execute_script(code_script_assign(signature_phone_tokens, index))
      end
      execute_script("document.getElementById('user-code-5').closest('form').submit()")
      sleep 0.5

      find('h1', text: 'Editer, imprimer et bientôt signer les conventions dématérialisées')
      assert_equal 1, Signature.all.count
      find('a.fr-btn.disabled', text: 'Signée, en attente')
    end

    test 'school_manager signs and everything is ok' do
      internship_agreement = create(:troisieme_generale_internship_agreement, :validated)
      school_manager = internship_agreement.school_manager
      sign_in(school_manager)

      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'

      find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer la convention de stage')
      find('input#phone-input').set('0612345678')
      click_button('Recevoir un code')

      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
      find('button.fr-btn[disabled]')
      signature_phone_tokens = school_manager.reload.signature_phone_token.split('')
      (0..5).to_a.each do |index|
        execute_script(code_script_enables(index))
        execute_script(code_script_assign(signature_phone_tokens, index))
      end
      execute_script("document.getElementById('user-code-5').closest('form').submit()")
      sleep 0.5

      find('h1', text: 'Editer, imprimer et bientôt signer les conventions dématérialisées')
      assert_equal 1, Signature.all.count
      find('a.fr-btn.disabled', text: 'Signée, en attente')
    end

    test 'employer signs and code is wrong' do
      internship_agreement = create(:troisieme_generale_internship_agreement, :validated)
      school_manager = internship_agreement.school_manager
      sign_in(school_manager)

      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'

      find('input#phone-input').set('0612345678')
      click_button('Recevoir un code')

      find('h1', text: 'Nous vous avons envoyé un code de vérification')
      find('button.fr-btn[disabled]')
      (0..5).to_a.each do |index|
        execute_script(code_script_enables(index))
        execute_script(code_script_assign(index, index))
      end
      execute_script("document.getElementById('user-code-5').closest('form').submit()")
      sleep 0.5

      find('h1', text: 'Editer, imprimer et bientôt signer les conventions dématérialisées')
      assert_equal 0, Signature.all.count
      find('span#alert-text', text: 'Erreur de code, veuillez recommencer')
    end
  end
end
