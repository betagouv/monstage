# frozen_string_literal: true

require 'application_system_test_case'

class SignInFlowTest < ApplicationSystemTestCase
  test 'not confirmed with email' do
    password = 'kikoolol'
    email = 'fourcade.m@gmail.com'
    user = create(:student, email: email,
                             password: password,
                             phone: nil,
                             confirmed_at: nil)

    visit new_user_session_path

    find('label', text: 'Email').click
    fill_in 'Adresse électronique', with: email
    fill_in 'Mot de passe', with: password
    click_on "Connexion"
    error_message = find('#alert-text').text
    assert_equal "Un message d’activation vous a été envoyé par courrier électronique. Veuillez suivre les instructions qu’il contient.",
                 error_message

    user.confirm
    visit new_user_session_path
    find('label', text: 'Email').click
    fill_in 'Adresse électronique', with: email
    fill_in 'Mot de passe', with: 'koko'
    click_on "Connexion"
    error_message = find('#alert-text').text
    assert_equal "Courriel ou mot de passe incorrect.",
                 error_message

    fill_in 'Mot de passe', with: password

    click_on "Connexion"
    find "a[href=\"#{account_path}\"]"
  end

   test 'not confirmed with phone' do
    password = 'kikoolol'
    phone = '+330637607756'
    user = create(:student, email: nil,
                             phone: phone,
                             password: password,
                             confirmed_at: nil)

    # go to signup as employer
    visit new_user_session_path

    # fails to create employer with existing email
    find('label', text: 'SMS').click
    execute_script("document.getElementById('phone-input').value = '#{phone}';")

    fill_in 'Mot de passe', with: password
    click_on "Connexion"
    error_message = find('#alert-text').text
    assert_equal "Un message d’activation vous a été envoyé par courrier électronique. Veuillez suivre les instructions qu’il contient.",
                 error_message

    user.confirm
    visit new_user_session_path
    find('label', text: 'SMS').click
    execute_script("document.getElementById('phone-input').value = '#{phone}';")
    fill_in 'Mot de passe', with: 'koko'
    click_on "Connexion"

    error_message = find('#alert-text').text
    assert_equal "Courriel ou mot de passe incorrect.",
                 error_message

    fill_in 'Mot de passe', with: password
    click_on "Connexion"
    find "a[href=\"#{account_path}\"]"
  end
end
