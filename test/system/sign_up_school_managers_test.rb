require "application_system_test_case"

class SignUpSchoolManagersTest < ApplicationSystemTestCase
  driven_by :selenium, using: :chrome

  test "navigation & interaction works until school manager creation" do
    existing_email = 'fourcade.m@gmail.com'

    # go to signup as student
    visit "/"
    click_on "Inscription"
    click_on "Je suis chef d'établissement"

    # fails to create student with existing email
    assert_difference('Users::SchoolManager.count', 0) do
      fill_in "Mon courriel professionnel", with: 'fourcade.m@gmail.com'
      fill_in "Mon mot de passe", with: "kikoololletest"
      fill_in "Confirmation de mon mot de passe", with: "kikoololletest"
      click_on "Je m'inscris"
    end

    # create student
    assert_difference('Users::SchoolManager.count', 1) do
      fill_in "Mon courriel professionnel", with: "fourcade.m@ac-mail.com"
      fill_in "Mon mot de passe", with: "kikoololletest"
      fill_in "Confirmation de mon mot de passe", with: "kikoololletest"
      click_on "Je m'inscris"
    end
  end
end
