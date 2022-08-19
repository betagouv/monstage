# frozen_string_literal: true

require 'application_system_test_case'
require 'pretty_console'

class SignUpEmployersTest < ApplicationSystemTestCase
  test 'navigation & interaction works until employer creation' do
    existing_email = 'fourcade.m@gmail.com'
    a_phone_number = '0625298847'
    create(:employer, email: existing_email)

    # go to signup as employer
    visit new_user_registration_path(as: 'Employer')

    # fails to create employer with existing email
    assert_difference('Users::Employer.count', 0) do
      fill_in 'Prénom', with: 'Madame'
      find("input[name='user[last_name]']").fill_in with: 'Accor'
      fill_in 'Adresse électronique (e-mail)', with: existing_email
      find("input[name='user[phone_suffix]']").fill_in with: a_phone_number
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      find('input[type="checkbox"]', visible: false).check
      click_on "Valider mes informations"
    end

    # create employer
    assert_difference('Users::Employer.count', 1) do
      fill_in 'Adresse électronique (e-mail)', with: 'another@gmail.com'
      find("input[name='user[phone_suffix]']").fill_in with: a_phone_number
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      click_on "Valider mes informations"
    end

    # check created employer has valid info
    created_employer = Users::Employer.find_by(email: 'another@gmail.com')
    refute created_employer.nil?
  end
end
