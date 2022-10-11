require 'application_system_test_case'

class ForgottenPasswordFlowTest < ApplicationSystemTestCase
  if ENV['RUN_BRITTLE_TEST'] && ENV['RUN_BRITTLE_TEST'] == 'true'
    test 'ask password change with wrong email raises an alert' do
      visit new_user_password_path
      find('label[for=select-channel-email]').click
      execute_script("document.getElementById('user_email').value = 'john@inexisting.fr';")
      click_button('Envoyer')
      find('label[for="user_email"]', text: 'Courriel introuvable')
    end

    test 'ask password change with existing email' do
      student = create(:student)
      success_text = 'Vous allez recevoir sous quelques minutes un ' \
                    'courriel vous indiquant comment réinitialiser votre mot de passe.'

      visit new_user_password_path
      find('label[for=select-channel-email]').click
      execute_script("document.getElementById('user_email').value = '#{student.email}';")

      click_button('Envoyer')
      find '#alert-success #alert-text', text: success_text
    end
  end
end
