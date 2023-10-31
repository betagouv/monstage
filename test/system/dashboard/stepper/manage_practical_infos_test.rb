
require 'application_system_test_case'

class ManagePracticalInfosTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include PracticalInfoFormFiller

  test 'can create PracticalInfos' do
    employer              = create(:employer)
    organisation          = create(:organisation, employer: employer)
    internship_offer_info = create(:weekly_internship_offer_info, employer: employer)
    hosting_info          = create(:hosting_info, employer: employer)
    sign_in(employer)
    visit new_dashboard_stepper_practical_info_path(organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id, hosting_info_id: hosting_info.id)
    find('span', text: 'Étape 4 sur 4')
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
