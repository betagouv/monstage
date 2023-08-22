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
    assert_difference('Users::PrefectureStatistician.count', 0) do
      fill_in 'Prénom', with: 'Martin'
      find("input[name='user[last_name]']").fill_in with: 'Fourcade'
      fill_in 'Adresse électronique', with: bad_email
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      execute_script("document.getElementById('user_accept_terms').checked = true;")
      click_on "Valider"
    end

    assert_equal 0, Users::PrefectureStatistician.count
    # assert_difference('Users::PrefectureStatistician.count', 1) do
    #   fill_in 'Prénom', with: 'Martin'
    #   fill_in 'Nom', with: 'Fourcade'
    #   choose 'Départemental'
    #   select('75', from: "user_department")
    #   fill_in 'Adresse électronique', with: good_email
    #   fill_in 'Créer un mot de passe', with: 'kikoololletest'
    #   execute_script("document.getElementById('user_accept_terms').checked = true;")
    #   click_on "Valider"
    # end

    # check created statistician has valid info
    # created_statistician = Users::PrefectureStatistician.find_by(email: good_email)
    # assert_equal 'Martin', created_statistician.first_name
    # assert_equal 'Fourcade', created_statistician.last_name
    # assert_equal false, created_statistician.agreement_signatorable
  end
end
