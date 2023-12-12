
require 'application_system_test_case'

class ManagePracticalInfosTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include PracticalInfoFormFiller

  test 'can create PracticalInfos' do
    travel_to Date.new(2020, 1, 1) do
      employer              = create(:employer)
      organisation          = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info, employer: employer)
      hosting_info          = create(:hosting_info, employer: employer)
      sign_in(employer)
      visit new_dashboard_stepper_practical_info_path(organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id, hosting_info_id: hosting_info.id)
      find('span', text: 'Étape 4 sur 5')
      find('h2', text: 'Informations pratiques')
      fill_in_practical_infos_form
      click_on "Suivant"
      assert_equal 1, PracticalInfo.count
      assert_equal "12:00-13:00 avec l'équipe", PracticalInfo.last.lunch_break
      assert_equal '+330623665555', PracticalInfo.last.contact_phone
      assert_equal '1 rue du poulet', PracticalInfo.last.street
      assert_equal '75001', PracticalInfo.last.zipcode
      assert_equal 'Paris', PracticalInfo.last.city
      assert_equal ["08:00", "16:30"], PracticalInfo.last.weekly_hours
      click_on "Publier"
      assert_equal 1, InternshipOffer.count
      assert_equal '+330623665555', InternshipOffer.last.contact_phone
      assert_equal '1 rue du poulet', InternshipOffer.last.street
      assert_equal '75001', InternshipOffer.last.zipcode
      assert_equal 'Paris', InternshipOffer.last.city
      assert_equal ["08:00", "16:30"], InternshipOffer.last.weekly_hours
    end
  end

  # test 'cannot create PracticalInfos with badly formatted field' do
  #   employer              = create(:employer)
  #   organisation          = create(:organisation, employer: employer)
  #   internship_offer_info = create(:internship_offer_info, employer: employer)
  #   hosting_info          = create(:hosting_info, employer: employer)
  #   sign_in(employer)
  #   visit new_dashboard_stepper_practical_info_path(organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id, hosting_info_id: hosting_info.id)
  #   find('span', text: 'Étape 4 sur 5')
  #   find('h2', text: 'Informations pratiques')
  #   fill_in_practical_infos_form
  #   fill_in 'Votre numéro de téléphone de correspondance', with: '+330f623665555' # bad phone number
  #   click_on "Suivant"
  #   assert_equal 0, PracticalInfo.count
  #   assert_equal 0, InternshipOffer.count
  #   find "h2", text: "Informations pratiques"
  #   within "fieldset.fr-mt-11v" do
  #     find "legend", text: "Adresse du stage"
  #   end
  #   find "p#text-input-error-desc-error-contact_phone",
  #        text: "Votre numéro de téléphone de correspondance : le numéro de téléphone doit contenir des caractères chiffrés uniquement"
  # end
end
