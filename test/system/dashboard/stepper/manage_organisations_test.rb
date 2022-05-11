# frozen_string_literal: true

require 'application_system_test_case'

class ManageOrganisationsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include OrganisationFormFiller

  test 'can create Organisation' do
    if ENV['RUN_BRITTLE_TEST'] && ENV['RUN_BRITTLE_TEST'] == 'true'# TODO remove after chromeversion issue
    2.times { create(:school) }
    employer = create(:employer)
    group = create(:group, name: 'hello', is_public: true)
    sign_in(employer)
    assert_difference 'Organisation.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit employer.custom_dashboard_path
        find('#test-create-offer').click
        fill_in_organisation_form(is_public: true, group: group)
        find('span.number', text: '1')
        find('span.number', text: '2')
        find('span.number', text: '3')
        click_on "Suivant"
      end
    end
    end
  end

  # test 'can edit organisation' do
  #   employer = create(:employer)
  #   organisation = create(:organisation)
  #   sign_in(employer)
  #   visit edit_dashboard_organisation_path(organisation)
  #   fill_in 'Nom de l’entreprise proposant l’offre', with: 'New name'

  #   click_on "Enregistrer et publier l'offre"
  #   assert_equal 'New name', organisation.reload.title
  # end

  test 'create organisation fails gracefuly' do
    if ENV['RUN_BRITTLE_TEST'] && ENV['RUN_BRITTLE_TEST'] == 'true'# TODO remove after chromeversion issue
    sector = create(:sector)
    employer = create(:employer)
    group = create(:group, name: 'hello', is_public: true)
    sign_in(employer)
    travel_to(Date.new(2019, 3, 1)) do
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      fill_in_organisation_form(is_public: true, group: group)
      as = 'a' * (InternshipOffer::EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT + 2)
      find('#organisation_employer_description_rich_text', visible: false).set(as)
      click_on "Suivant"
      find('#error_explanation')
    end
    end
  end
end
