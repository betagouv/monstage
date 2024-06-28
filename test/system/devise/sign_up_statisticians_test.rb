# frozen_string_literal: true

require 'application_system_test_case'

class SignUpStatisticiansTest < ApplicationSystemTestCase
  test 'navigation & interaction works until statistician creation' do
    # go to signup as statistician
    bad_email = 'lol@lol.fr'
    good_email = 'kikoolol@gmail.com'
    password = 'Kikoo4test;123'

    visit new_user_registration_path(as: 'Statistician')

    assert_difference('Users::PrefectureStatistician.count', 1) do
      fill_in 'Prénom', with: 'Martin'
      fill_in 'Nom', with: 'Fourcade'
      execute_script("document.getElementById('user_statistician_department_type').checked=true;")
      execute_script("document.getElementById('statistician-department').classList.remove('d-none');")
      execute_script("document.getElementById('new_user').action = '/utilisateurs?as=PrefectureStatistician';")
      # choose 'Départemental'
      select('75', from: "user_department")
      fill_in 'Adresse électronique', with: good_email
      fill_in 'Créer un mot de passe', with: password
      execute_script("document.getElementById('user_accept_terms').checked = true;")
      click_on "Valider"
    end

    # check created statistician has valid info
    created_statistician = Users::PrefectureStatistician.find_by(email: good_email)
    assert_equal 'Martin', created_statistician.first_name
    assert_equal 'Fourcade', created_statistician.last_name
    assert_equal false, created_statistician.agreement_signatorable
  end
end
