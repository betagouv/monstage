# frozen_string_literal: true

require 'application_system_test_case'

class SignUpEmployersTest < ApplicationSystemTestCase
  test 'navigation & interaction works until employer creation' do
    existing_email = 'fourcade.m@gmail.com'
    create(:employer, email: existing_email)

    # go to signup as employer
    visit new_user_registration_path(as: 'Employer')

    # fails to create employer with existing email
    assert_difference('Users::Employer.count', 0) do
      fill_in 'Prénom', with: 'Madame'
      find("input[name='user[last_name]']").fill_in with: 'Accor'
      fill_in 'Adresse électronique', with: existing_email
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      find('label[for="user_accept_terms"]').click
      click_on "Je m'inscris"
    end

    # create employer
    assert_difference('Users::Employer.count', 1) do
      fill_in 'Prénom', with: 'Madame'
      find("input[name='user[last_name]']").fill_in with: 'Accor'
      fill_in 'Adresse électronique', with: 'another@email.com'
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      click_on "Je m'inscris"
    end

    # check created employer has valid info
    created_employer = Users::Employer.where(email: 'another@email.com').first
    # find('p.h2', text:'1 . Activez votre compte !')
  end
end
