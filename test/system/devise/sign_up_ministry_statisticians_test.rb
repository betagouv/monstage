# frozen_string_literal: true

require 'application_system_test_case'

class SignUpMinistryStatisticiansTest < ApplicationSystemTestCase
  test 'navigation & interaction works until ministry statistician creation' do

    # create ministry_statistician with previously set email
    create(:public_group, name: 'Ministère de la Justice')
    create(:public_group, name: "Ministère de l'intérieur")
    visit new_user_registration_path(as: 'Statistician')
    email = 'kikoolol@gmail.com'
    assert Group.is_public.count > 1
    assert_difference('Users::MinistryStatistician.count', 1) do
      fill_in 'Prénom', with: 'Martin'
      find("input[name='user[last_name]']").fill_in(with: 'Fourcade')
      execute_script("document.getElementById('user_statistician_ministry_type').checked=true;")
      execute_script("document.getElementById('statistician-ministry').classList.remove('d-none');")
      execute_script(" document.getElementById('new_user').action = '/utilisateurs?as=MinistryStatistician';")
      select("Ministère de la Justice", from: "Choisissez le ministère correspondant")
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
