# frozen_string_literal: true

require 'application_system_test_case'

class ManageInternshipOfferInfosTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include InternshipOfferInfoFormFiller

  test 'can create HostingInfo' do
    sector = create(:sector)
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    internship_offer_info = create(:internship_offer_info, employer: employer)
    school_name = 'Abd El Kader'  
    school = create(:school, city: 'Paris', zipcode: 75012, name: school_name)

    sign_in(employer)
    assert_difference 'HostingInfo.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_hosting_info_path(organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id)
        find('span', text: 'Étape 3 sur 5')
        # Individual internship
        find('label[for="internship_type_true"]').click
        fill_in("hosting_info_max_candidates", with: 1)
        find('.test-school-reserved').click
        fill_in('Ville ou nom de l\'établissement pour lequel le stage est reservé', with: 'Pari')
        all('.autocomplete-school-results .list-group-item-action').first.click
        select(school_name, from: 'Collège')
        click_on "Suivant"
        find('span', text: 'Étape 4 sur 5')
        find('h2', text: 'Informations pratiques')
      end
    end
  end
end
