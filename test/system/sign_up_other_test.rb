# frozen_string_literal: true

require 'application_system_test_case'

class SignUpOthersTest < ApplicationSystemTestCase
  test 'navigation & interaction works until other creation' do
    school_1 = create(:school, name: 'Collège Test 1', city: 'Saint-Martin', zipcode: '77515')
    school_manager = create(:school_manager, school: school_1)
    school_2 = create(:school, name: 'Collège Test 2', city: 'Saint-Parfait')
    existing_email = 'fourcade.m@gmail.com'
    student = create(:student, email: existing_email)
    # go to signup as other
    visit new_user_registration_path(as: 'SchoolManagement')

    # fails to create other with existing email
    assert_difference('Users::SchoolManagement.count', 0) do
      find_field('Nom (ou ville) de mon collège').fill_in(with: 'Saint')
      all('.list-group .list-group-item-action').first.click
      find("label[for=\"select-school-#{school_1.id}\"]").click

      fill_in 'Prénom', with: 'Martin'
      find("input[name='user[last_name]']").fill_in  with: 'Fourcade'
      fill_in 'Adresse électronique', with: existing_email
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      find('#test-accept-terms').click
      click_on "Je m'inscris"
    end

    # create other
    assert_difference('Users::SchoolManagement.count', 1) do
      find_field('Nom (ou ville) de mon collège').fill_in(with: 'Saint')
      # find('button', text: school_1.city).click
      all('.list-group .list-group-item-action').first.click
      find("label[for=\"select-school-#{school_1.id}\"]").click
      fill_in 'Adresse électronique', with: 'another@email.com'
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      click_on "Je m'inscris"
    end

    # check created other has valid info
    other = Users::SchoolManagement.where(email: 'another@email.com').first
    assert_equal school_1, other.school
    assert_equal 'Martin', other.first_name
    assert_equal 'Fourcade', other.last_name
  end
end
