require "application_system_test_case"

class SignUpEmployersTest < ApplicationSystemTestCase
  driven_by :selenium, using: :chrome

  test "navigation & interaction works until employer creation" do
    existing_email = 'fourcade.m@gmail.com'
    create(:employer, email: existing_email)

    # go to signup as student
    visit "/"
    click_on "Inscription"
    click_on "Je veux déposer une offre"

    # fails to create student with existing email
    assert_difference('Users::Employer.count', 0) do
      fill_in "Mon courriel", with: existing_email
      fill_in "Mon mot de passe", with: "kikoololletest"
      fill_in "Confirmation de mon mot de passe", with: "kikoololletest"
      click_on "Je m'inscris"
    end

    # create student
    assert_difference('Users::Employer.count', 1) do
      fill_in "Mon courriel", with: "another@email.com"
      fill_in "Mon mot de passe", with: "kikoololletest"
      fill_in "Confirmation de mon mot de passe", with: "kikoololletest"
      click_on "Je m'inscris"
    end

    # check created student has valid info
    created_student = Users::Employer.where(email: "another@email.com").first
  end
end
