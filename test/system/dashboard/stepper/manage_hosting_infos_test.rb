# frozen_string_literal: true

require 'application_system_test_case'

class ManageInternshipOfferInfosTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include InternshipOfferInfoFormFiller

  test 'can create HostingInfo' do
    sector = create(:sector)
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    internship_offer_info = create(:weekly_internship_offer_info, employer: employer)

    sign_in(employer)
    assert_difference 'HostingInfo.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_hosting_info_path(organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id)
        find('span', text: 'Étape 3 sur 4')
        # Individual internship
        find('label[for="internship_type_true"]').click
        fill_in("hosting_info_max_candidates", with: 2)
        click_on "Suivant"
        find('span', text: 'Étape 4 sur 4')
        find('h2', text: 'Informations pratiques')
      end
    end
  end
end
