# frozen_string_literal: true

require 'application_system_test_case'

class ManageOrganisationsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def fill_in_form(is_public:, group:)
    fill_in 'Nom de l’entreprise proposant l’offre', with: 'Stage de dev @betagouv.fr ac Brice & Martin'
    find('label', text: 'Public').click
    select group.name, from: 'organisation_group_id' if group

    find('#internship_offer_autocomplete').fill_in(with: 'Paris, 13eme')
    find('#test-input-full-address #downshift-2-item-0').click
    fill_in "Rue ou compléments d'adresse", with: "La rue qui existe pas dans l'API / OSM"

    find('#organisation_employer_description_rich_text', visible: false).set("Une super cool entreprise")
    fill_in 'Site web (optionnel)', with: 'https://beta.gouv.fr/'
  end

  test 'can create Organisation' do
    schools = [create(:school), create(:school)]
    employer = create(:employer)
    group = create(:group, name: 'hello', is_public: true)
    sign_in(employer)
    assert_difference 'Organisation.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit employer.custom_dashboard_path
        find('#test-create-offer').click
        fill_in_form(is_public: true, group: group)
        click_on "Suivant"
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
    sector = create(:sector)
    employer = create(:employer)
    group = create(:group, name: 'hello', is_public: true)
    sign_in(employer)
    travel_to(Date.new(2019, 3, 1)) do
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      fill_in_form(is_public: true, group: group)
      as = 'a' * (InternshipOffer::EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT + 2)
      find('#organisation_employer_description_rich_text', visible: false).set(as)
      click_on "Suivant"
      find('#error_explanation')
    end
  end
end
