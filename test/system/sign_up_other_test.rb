# frozen_string_literal: true

require 'application_system_test_case'

class SignUpOthersTest < ApplicationSystemTestCase
  test 'navigation & interaction works until other creation' do
    school_1 = create(:school, name: 'Collège Test 1', city: 'Saint-Martin')
    school_manager = create(:school_manager, school: school_1)
    school_2 = create(:school, name: 'Collège Test 2', city: 'Saint-Parfait')
    existing_email = 'fourcade.m@gmail.com'

    # go to signup as other
    visit new_user_registration_path(as: 'Other')

    # fails to create other with existing email
    assert_difference('Users::Other.count', 0) do
      find_field('Ville de mon collège').fill_in(with: 'Saint')
      find('a', text: school_2.city).click
      find('label', text: "#{school_2.name} - #{school_2.city}").click
      fill_in 'Prénom', with: 'Martin'
      fill_in 'Nom', with: 'Fourcade'
      fill_in 'Adresse électronique', with: existing_email
      fill_in 'Choisir un mot de passe', with: 'kikoololletest'
      fill_in 'Confirmer le mot de passe', with: 'kikoololletest'
      click_on "Je m'inscris"
    end

    # ensure failure reset form as expected
    assert_equal school_2.city,
                 find_field('Ville de mon collège').value,
                 're-select of city after failure fails'

    # create other
    assert_difference('Users::Other.count', 1) do
      find_field('Ville de mon collège').fill_in(with: 'Saint')
      find('a', text: school_1.city).click
      find('label', text: "#{school_1.name} - #{school_1.city}").click
      fill_in 'Adresse électronique', with: 'another@email.com'
      fill_in 'Choisir un mot de passe', with: 'kikoololletest'
      fill_in 'Confirmer le mot de passe', with: 'kikoololletest'
      click_on "Je m'inscris"
    end

    # check created other has valid info
    other = Users::Other.where(email: 'another@email.com').first
    assert_equal school_1, other.school
    assert_equal 'Martin', other.first_name
    assert_equal 'Fourcade', other.last_name
  end
end
