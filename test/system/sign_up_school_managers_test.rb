# frozen_string_literal: true

require 'application_system_test_case'

class SignUpSchoolManagersTest < ApplicationSystemTestCase
  test 'navigation & interaction works until school manager creation' do
    existing_email = 'fourcade.m@gmail.com'
    school_1 = create(:school, name: 'Collège Test 1', city: 'Saint-Martin')
    create(:student, email: existing_email)
    # go to signup as school_manager
    visit new_user_registration_path(as: 'SchoolManager')

    # fails to create school_manager with existing email
    assert_difference('Users::SchoolManager.count', 0) do
      find_field('Ville ou nom de mon collège').fill_in(with: 'Saint')
      all('.list-group .list-group-item-action').first.click
      find("label[for=\"select-school-#{school_1.id}\"]").click
      fill_in 'Adresse électronique académique', with: 'fourcade.m@gmail.com'
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Prénom', with: 'Martin'
      fill_in 'Nom', with: 'Fourcade'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      find('label[for="user_accept_terms"]').click
      click_on "Je m'inscris"
    end

    # create school_manager
    assert_difference('Users::SchoolManager.count', 1) do
      find_field('Ville ou nom de mon collège').fill_in(with: 'Saint')
      all('.list-group .list-group-item-action').first.click
      find("label[for=\"select-school-#{school_1.id}\"]").click

      fill_in 'Adresse électronique académique', with: 'fourcade.m@ac-mail.com'
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      fill_in 'Prénom', with: 'Martin'
      fill_in 'Nom', with: 'Fourcade'
      click_on "Je m'inscris"
    end
  end
end
