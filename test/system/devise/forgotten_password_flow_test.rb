require 'application_system_test_case'

class ForgottenPasswordFlowTest < ApplicationSystemTestCase
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

  test 'ask password change with wrong email raises an alert - SMS version' do
    visit new_user_password_path
    choose 'SMS'
    choose 'Email'
    find('#user_email')
    fill_in('user_email', with: 'john@inexisting.fr')
    click_button('Envoyer')
    find('label[for="user_email"]', text: 'Courriel introuvable')
  end

  test 'ask password change with existing email - SMS version' do
    student = create(:student)
    success_text = 'Vous allez recevoir sous quelques minutes un ' \
                   'courriel vous indiquant comment réinitialiser votre mot de passe.'

    visit new_user_password_path
    choose 'SMS'
    choose 'Email'
    find('#user_email')
    fill_in('user_email', with: student.email)
    click_button('Envoyer')
    find '#alert-success #alert-text', text: success_text
  end
end
