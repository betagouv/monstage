require "application_system_test_case"

class SignUpSchoolManagersTest < ApplicationSystemTestCase
  test "navigation & interaction works until school manager creation" do
    existing_email = 'fourcade.m@gmail.com'

    # go to signup as school_manager
    visit_signup
    click_on "Je suis chef d'établissement"

    # fails to create school_manager with existing email
    assert_difference('Users::SchoolManager.count', 0) do
      fill_in "Adresse électronique académique", with: 'fourcade.m@gmail.com'
      fill_in "Mot de passe", with: "kikoololletest"
      fill_in "Confirmation de mon mot de passe", with: "kikoololletest"
      click_on "Je m'inscris"
    end

    # create school_manager
    assert_difference('Users::SchoolManager.count', 1) do
      fill_in "Adresse électronique académique", with: "fourcade.m@ac-mail.com"
      fill_in "Mot de passe", with: "kikoololletest"
      fill_in "Confirmation de mon mot de passe", with: "kikoololletest"
      click_on "Je m'inscris"
    end
  end
end
