require "application_system_test_case"

class SignUpEmployersTest < ApplicationSystemTestCase
  test "navigation & interaction works until employer creation" do
    existing_email = 'fourcade.m@gmail.com'
    create(:employer, email: existing_email)

    # go to signup as employer
    visit "/"
    click_on "Inscription"
    click_on "Je veux déposer une offre"

    # fails to create employer with existing email
    assert_difference('Users::Employer.count', 0) do
      fill_in "Mon courriel", with: existing_email
      fill_in "Mon mot de passe", with: "kikoololletest"
      fill_in "Confirmation de mon mot de passe", with: "kikoololletest"
      click_on "Je m'inscris"
    end

    # create employer
    assert_difference('Users::Employer.count', 1) do
      fill_in "Mon courriel", with: "another@email.com"
      fill_in "Mon mot de passe", with: "kikoololletest"
      fill_in "Confirmation de mon mot de passe", with: "kikoololletest"
      click_on "Je m'inscris"
    end

    # check created employer has valid info
    created_employer = Users::Employer.where(email: "another@email.com").first
  end
end
