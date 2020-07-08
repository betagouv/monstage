# frozen_string_literal: true

require 'application_system_test_case'

class PasswordFlowTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  test 'ask new password with email' do
    password = 'kikoolol'
    email = 'fourcade.m@gmail.com'
    user = create(:student, email: email,
                            password: password,
                            phone: nil,
                            confirmed_at: Time.now.utc)

    assert_changes -> { user.reload.reset_password_token } do
      visit new_user_password_path
      find('label', text: 'Email').click
      fill_in 'Adresse électronique', with: email
      click_on 'Envoyer'
      success_message = find('#alert-text').text
      assert_equal success_message,
                   'Vous allez recevoir sous quelques minutes un courriel vous indiquant comment réinitialiser votre mot de passe.'
    end
    token = user.send_reset_password_instructions
    assert_changes -> { user.reload.reset_password_token } do
      visit edit_user_password_path(reset_password_token: token)
      fill_in('Nouveau mot de passe', with: 'okokok')
      fill_in('Confirmez votre nouveau mot de passe', with: 'okokok')
      click_on('Changer mon mot de passe')
    end
    success_message = find('#alert-text').text
    assert_equal success_message,
                 'Votre mot de passe a bien été modifié. Vous êtes maintenant connecté(e).'
  end

  test 'ask new password with phone' do
    password = 'kikoolol'
    phone = '+330637607756'
    user = create(:student, email: nil,
                            phone: phone,
                            password: password,
                            confirmed_at: Time.now.utc)

    visit new_user_password_path
    find('label', text: 'SMS').click
    execute_script("document.getElementById('phone-input').value = '#{phone}';")
    click_on 'Envoyer'
    user.reload
    execute_script("document.getElementById('phone-input').value = '#{phone}';")
    fill_in 'Code de confirmation', with: user.phone_token
    fill_in('Nouveau mot de passe', with: 'okokok')
    fill_in('Confirmez votre nouveau mot de passe', with: 'okokok')
    click_on 'Valider'

    success_message = find('#alert-text').text
    assert_equal success_message,
                 'Votre mot de passe a bien été modifié. Vous êtes maintenant connecté(e).'
  end
end
