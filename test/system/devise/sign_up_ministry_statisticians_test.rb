# frozen_string_literal: true

require 'application_system_test_case'

class SignUpMinistryStatisticiansTest < ApplicationSystemTestCase
  test 'navigation & interaction works until ministry statistician creation' do
    # go to signup as statistician
    
    email = 'kikoolol_levrai@gmail.com'
    create(:ministry_statistician_email_whitelist, email: email)
    bad_email = 'lol@lol.fr'

    visit new_user_registration_path(as: 'MinistryStatistician')

    # fails to create ministry_statistician with unexisting email
    assert_difference('Users::MinistryStatistician.count', 0) do
      fill_in 'Prénom', with: 'Martin'
      find("input[name='user[last_name]']").fill_in(with: 'Fourcade')
      fill_in 'Adresse électronique', with: bad_email
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      execute_script("document.getElementById('user_accept_terms').checked = true;")
      click_on "Valider"
    end

    # create ministry_statistician with previously set email
    visit new_user_registration_path(as: 'MinistryStatistician')
    assert_difference('Users::MinistryStatistician.count', 1) do
      fill_in 'Prénom', with: 'Martin'
      find("input[name='user[last_name]']").fill_in(with: 'Fourcade')
      choose 'Administration centrale'
      select(Group.public.first.name, from: "user_group_id")
      fill_in 'Adresse électronique', with: email
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      execute_script("document.getElementById('user_accept_terms').checked = true;")
      click_on "Valider"
    end

    # check created statistician has valid info
    created_ministry_statistician = Users::MinistryStatistician.where(email: email).last
    assert_equal 'Martin', created_ministry_statistician.first_name
    assert_equal 'Fourcade', created_ministry_statistician.last_name
  end
end
