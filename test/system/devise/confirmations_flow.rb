# frozen_string_literal: true

require 'application_system_test_case'

class ConfirmationFlowTest < ApplicationSystemTestCase
  test 'ask notification confirmed with email' do
    password = 'kikoolol'
    email = 'fourcade.m@gmail.com'
    user = create(:student, email: email,
                            password: password,
                            phone: nil,
                            confirmed_at: nil)

    visit new_user_confirmation_path
    find('label', text: 'Email').click
    fill_in 'Adresse électronique', with: email
    click_on 'Renvoyer'
    user.reload
    assert_changes -> { user.reload.confirmed? },
                   from: false,
                   to: true do
      visit user_confirmation_path(confirmation_token: user.confirmation_token)
    end
  end

  test 'ask notification confirmed with phone' do
    phone = '+330637607756'
    user = create(:student, email: nil,
                            phone: phone,
                            confirmed_at: nil)

    visit new_user_confirmation_path
    find('label', text: 'SMS').click
    execute_script("document.getElementById('phone-input').value = '#{phone}';")
    click_on 'Renvoyer'
    user.reload
    assert_changes -> { user.reload.confirmed? },
                   from: false,
                   to: true do
      fill_in 'Code de confirmation', with: user.phone_token
      click_on 'Valider'
    end
  end

  test 'register confirmation done with wrong phone number' do
    phone       = '+330637607756'
    wrong_phone = '+330637607750'
    user = create(:student, email: nil,
                            phone: phone,
                            confirmed_at: nil)

    visit new_user_confirmation_path
    find('label', text: 'SMS').click
    execute_script("document.getElementById('phone-input').value = '#{wrong_phone}';")
    click_on 'Renvoyer'
    find('#error_explanation label', text:'Veuillez saisir un email ou un numéro de téléphone')
  end

  test 'register confirmation confirmed with phone number while subscribed with email' do
    phone = '+330637607756'
    user  = create(:student, email: 'test@test.fr',
                             phone: nil,
                             confirmed_at: nil)

    visit new_user_confirmation_path
    find('label', text: 'SMS').click
    execute_script("document.getElementById('phone-input').value = '#{phone}';")
    click_on 'Renvoyer'
    find '#error_explanation label',
         text: 'Veuillez saisir un email ou un numéro de téléphone'
  end
end
