require "application_system_test_case"

class SignUpSchoolManagersTest < ApplicationSystemTestCase
  test "navigation & interaction works until school manager creation" do
    existing_email = 'fourcade.m@gmail.com'
    school_1 = create(:school, name: "Collège Test 1", city: "Saint-Martin")

    # go to signup as school_manager
    visit_signup
    click_on "Je suis chef d'établissement"

    # fails to create school_manager with existing email
    assert_difference('Users::SchoolManager.count', 0) do
      find_field("Ville de mon collège").fill_in(with: "Saint")
      find("a", text: school_1.city).click
      find("label", text: "#{school_1.name} - #{school_1.city}").click
      fill_in "Adresse électronique académique", with: 'fourcade.m@gmail.com'
      fill_in "Choisir un mot de passe", with: "kikoololletest"
      fill_in "Prénom", with: "Martin"
      fill_in "Nom", with: "Fourcade"
      fill_in "Confirmer le mot de passe", with: "kikoololletest"
      click_on "Je m'inscris"
    end

    # create school_manager
    assert_difference('Users::SchoolManager.count', 1) do
      find_field("Ville de mon collège").fill_in(with: "Saint")
      find("a", text: school_1.city).click
      find("label", text: "#{school_1.name} - #{school_1.city}").click
      fill_in "Adresse électronique académique", with: "fourcade.m@ac-mail.com"
      fill_in "Choisir un mot de passe", with: "kikoololletest"
      fill_in "Confirmer le mot de passe", with: "kikoololletest"
      fill_in "Prénom", with: "Martin"
      fill_in "Nom", with: "Fourcade"
      click_on "Je m'inscris"
    end
  end
end
