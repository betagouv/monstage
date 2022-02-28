# frozen_string_literal: true

require 'application_system_test_case'

class SignUpStatisticiansTest < ApplicationSystemTestCase
  test 'navigation & interaction works until statistician creation' do
    # go to signup as statistician
    bad_email = 'lol@lol.fr'
    good_email = 'kikoolol@gmail.com'

    create(:statistician_email_whitelist, email: good_email, zipcode: 60)

    visit new_user_registration_path(as: 'Statistician')

    # fails to create statistician with unexisting email in whitelist
    assert_difference('Users::Statistician.count', 0) do
      fill_in 'Prénom', with: 'Martin'
      find("input[name='user[last_name]']").fill_in with: 'Fourcade'
      fill_in 'Adresse électronique', with: bad_email
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      find('label[for="user_accept_terms"]').click
      click_on "Je m'inscris"
    end

    assert_equal 0, Users::Statistician.count
    assert_difference('Users::Statistician.count', 1) do
      fill_in 'Adresse électronique', with: good_email
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      # find('label[for="user_accept_terms"].fr-label').click
      click_on "Je m'inscris"
    end

    # check created statistician has valid info
    created_statistician = Users::Statistician.find_by(email: good_email)
    assert_equal 'Martin', created_statistician.first_name
    assert_equal 'Fourcade', created_statistician.last_name
  end
end
