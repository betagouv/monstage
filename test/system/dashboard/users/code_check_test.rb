require 'application_system_test_case'
module Dashboard::Users
  class CodeCheckTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    def code_script_enables(index)
      "document.getElementById('user-code-#{index}').disabled=false"
    end
    def code_script_assign(signature_phone_tokens, index)
      "document.getElementById('user-code-#{index}').value=#{signature_phone_tokens[index]}"
    end


    test 'employer signs and everything is ok' do
      internship_agreement = create(:internship_agreement, :validated)
      employer = internship_agreement.employer
      sign_in(employer)

      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'
      click_on 'Signer'

      find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer 1 convention de stage')
      find('input#phone_suffix').set('0612345678')
      click_button('Recevoir un code')

      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
      find("button#button-code-submit.fr-btn[disabled]")
      signature_phone_tokens = employer.reload.signature_phone_token.split('')
      (0..5).to_a.each do |index|
        execute_script(code_script_enables(index))
        execute_script(code_script_assign(signature_phone_tokens, index))
      end
      find("#button-code-submit")
      execute_script("document.getElementById('button-code-submit').removeAttribute('disabled')")
      within('dialog') do
        click_button('Signer la convention')
      end
    end

    test 'employer signs and code is wrong' do
      internship_agreement = create(:internship_agreement, :validated)
      school_manager = internship_agreement.school_manager
      sign_in(school_manager)

      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'
      click_on 'Signer'

      find('input#phone_suffix').set('0612345678')
      click_button('Recevoir un code')

      find('h1', text: 'Nous vous avons envoyé un code de vérification')
      find("button#button-code-submit.fr-btn[disabled]")
      (0..5).to_a.each do |index|
        execute_script(code_script_enables(index))
        execute_script(code_script_assign(index, index)) # wrong code
      end
      find("#button-code-submit")
      execute_script("document.getElementById('button-code-submit').removeAttribute('disabled')")
      within('dialog') do
        click_button('Signer la convention')
      end
      if ENV['RUN_BRITTLE_TEST']
        find('h1', text: 'Editer, imprimer et bientôt signer les conventions dématérialisées')
      end

      assert_equal 0, Signature.all.count
      find('.fr-alert p', text: 'Erreur de code, veuillez recommencer')
    end
  end
end