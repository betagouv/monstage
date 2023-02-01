# frozen_string_literal: true

require 'application_system_test_case'

class ManageOrganisationsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include OrganisationFormFiller
  include StubsForApiGouvRequests

  setup do
    stub_gouv_api_requests
  end

  test 'can create Organisation' do
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
    organisation = Organisation.last
    assert_equal '18 RUE DE COTTE', organisation.street
    assert_equal 'PARIS 12', organisation.city
    assert_equal '75012', organisation.zipcode
    assert_equal Coordinates.paris_12[:longitude], organisation.coordinates.longitude
    assert_equal Coordinates.paris_12[:latitude], organisation.coordinates.latitude
  end

  test 'create organisation fails gracefuly' do
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


  # EDIT

  test 'can edit organisation when organisation pre-exists' do
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    internship_offer_info = create(:internship_offer_info, employer: employer)
    tutor = create(:tutor)
    internship_offer = create(
      :weekly_internship_offer,
      organisation: organisation,
      employer: employer,
      internship_offer_info: internship_offer_info,
      tutor: tutor
    )
    sign_in(employer)
    visit dashboard_internship_offer_path(internship_offer)
    click_on 'Modifier'
    find('h1', text: 'Modifier une offre de stage')
    page.assert_selector('button[aria-controls="tabpanel-internship-panel"]', text: 'Modifier le stage')
    page.assert_selector('button[aria-controls="tabpanel-tutor-panel"]', text: 'Modifier le tuteur de stage')
    within('.container-downshift') do
      find('.fr-text--lg.fr-mb-2w', text: "Adresse de l'entreprise ou de l'administration")
    end

    click_link('... ou faire une recherche')
    fill_in 'Rechercher votre société dans l’Annuaire des Entreprises', with: '90943224700015'
    within('.container-downshift') do
      within('ul') do
        all('li').first.click
      end
    end
    select(Group.is_public.order(:name).second.name)
    fill_in('Site web (optionnel)', with: 'https://www.ina.fr')
    find('input[type="submit"]').click
    find('span#alert-text', text: 'Les modifications sont enregistrées')
    organisation = organisation.reload
    assert_equal 'EAST SIDE SOFTWARE', organisation.employer_name
    assert_equal Group.is_public.order(:name).second.name, organisation.group.name
    assert_equal 'https://www.ina.fr', organisation.employer_website
    assert_equal '90943224700015', organisation.siret
    assert_equal '18 RUE DE COTTE', organisation.street
    assert_equal '75012', organisation.zipcode
    assert_equal 'PARIS 12', organisation.city
    internship_offer = internship_offer.reload
    assert_equal organisation.id, internship_offer.organisation.id
    assert_equal organisation.employer_name, internship_offer.employer_name
    assert_equal organisation.employer_website, internship_offer.employer_website
    assert_equal organisation.siret, internship_offer.siret
    assert_equal organisation.street, internship_offer.street
    assert_equal organisation.zipcode, internship_offer.zipcode
    assert_equal organisation.city, internship_offer.city
    assert_equal organisation.coordinates.longitude, internship_offer.coordinates.longitude
    assert_equal organisation.coordinates.latitude, internship_offer.coordinates.latitude
  end

  test 'can edit organisation when organisation does not pre-exists' do
    internship_offer = create( :weekly_internship_offer )
    employer = internship_offer.employer
    assert internship_offer.valid?
    sign_in(employer)
    visit dashboard_internship_offer_path(internship_offer)
    click_on 'Modifier'
    find('h1', text: 'Modifier une offre de stage')
    assert_css('.fr-tabs ul li button#tabpanel-headquarters')
    refute_css('.fr-tabs ul li button#tabpanel-internship')
    refute_css('.fr-tabs ul li button#tabpanel-tutor')

    find('.fr-text--lg.fr-mb-2w', text: "Adresse de l'entreprise ou de l'administration")

    organisation = internship_offer.reload.organisation
    internship_offer_info = internship_offer.internship_offer_info
    tutor = internship_offer.tutor

    refute organisation.nil?
    refute internship_offer_info.nil?
    refute tutor.nil?

    click_link('... ou faire une recherche')
    fill_in 'Rechercher votre société dans l’Annuaire des Entreprises', with: '90943224700015'
    within('.container-downshift') do
      within('ul') do
        all('li').first.click
      end
    end
    fill_in('Site web (optionnel)', with: 'https://www.ina.fr')
    find('input[type="submit"]').click
    find('span#alert-text', text: 'Les modifications sont enregistrées')
    assert_css('.fr-tabs ul li button#tabpanel-headquarters')
    assert_css('.fr-tabs ul li button#tabpanel-internship')
    assert_css('.fr-tabs ul li button#tabpanel-tutor')
  end

  test 'fails gracefully when editing organisation when pre-exists with missing parameters' do
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    internship_offer_info = create(:internship_offer_info, employer: employer)
    tutor = create(:tutor)
    internship_offer = create(
      :weekly_internship_offer,
      organisation: organisation,
      employer: employer,
      internship_offer_info: internship_offer_info,
      tutor: tutor
    )
    sign_in(employer)
    visit dashboard_internship_offer_path(internship_offer)
    click_on 'Modifier'
    find('h1', text: 'Modifier une offre de stage')
    within('.container-downshift') do
      find('.fr-text--lg.fr-mb-2w', text: "Adresse de l'entreprise ou de l'administration")
    end
    click_link('... ou faire une recherche')

    # Mistaking here
    fill_in 'Rechercher votre société dans l’Annuaire des Entreprises', with: ''

    select(Group.is_public.order(:name).second.name)
    fill_in('Site web (optionnel)', with: 'https://www.ina.fr')
    find('input[type="submit"]').click
    assert_select()
    within('#error_explanation.alert.alert-danger') do
      find('p', text: '4 erreurs à corriger')
    end
    # Following lines are special because errors are shown with internship_offer identifiers and not organisation identifiers
    find('li label[for="internship_offer_employer_name"]', text: "Veuillez saisir le nom de l'employeur")
    find('li label[for="internship_offer_street"]', text: "Veuillez renseigner la rue de l'adresse de l'offre de stage")
    find('li label[for="internship_offer_zipcode"]', text: "Veuillez renseigner le code postal de l'employeur")
    find('li label[for="internship_offer_city"]', text: "Veuillez renseigner la ville l'employeur")
    assert_equal 'MyCorp', organisation.reload.employer_name
  end

  test 'fails gracefully when editing organisation with search address editing with missing parameters' do
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    internship_offer_info = create(:internship_offer_info, employer: employer)
    tutor = create(:tutor)
    internship_offer = create(
      :weekly_internship_offer,
      organisation: organisation,
      employer: employer,
      internship_offer_info: internship_offer_info,
      tutor: tutor
    )
    sign_in(employer)
    visit dashboard_internship_offer_path(internship_offer)
    click_on 'Modifier'
    find('h1', text: 'Modifier une offre de stage')
    within('.container-downshift') do
      find('.fr-text--lg.fr-mb-2w', text: "Adresse de l'entreprise ou de l'administration")
    end
    click_link('... ou faire une recherche')

    # Mistaking here
    fill_in 'Rechercher votre société dans l’Annuaire des Entreprises', with: ''

    select(Group.is_public.order(:name).second.name)
    fill_in('Site web (optionnel)', with: 'https://www.ina.fr')
    find('input[type="submit"]').click
    assert_select()
    within('#error_explanation.alert.alert-danger') do
      find('p', text: '4 erreurs à corriger')
    end
    # Following lines are special because errors are shown with internship_offer identifiers and not organisation identifiers
    find('li label[for="internship_offer_employer_name"]', text: "Veuillez saisir le nom de l'employeur")
    find('li label[for="internship_offer_street"]', text: "Veuillez renseigner la rue de l'adresse de l'offre de stage")
    find('li label[for="internship_offer_zipcode"]', text: "Veuillez renseigner le code postal de l'employeur")
    find('li label[for="internship_offer_city"]', text: "Veuillez renseigner la ville l'employeur")
    assert_equal 'MyCorp', organisation.reload.employer_name
  end

  test 'can edit organisation with manual address editing' do
    Group.create(name: 'private_corpo', is_public: false, is_paqte: false)
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    internship_offer_info = create(:internship_offer_info, employer: employer)
    tutor = create(:tutor)
    internship_offer = create(
      :weekly_internship_offer,
      organisation: organisation,
      employer: employer,
      internship_offer_info: internship_offer_info,
      tutor: tutor
    )
    sign_in(employer)
    visit dashboard_internship_offer_path(internship_offer)
    click_on 'Modifier'
    click_link('... ou faire une recherche')
    click_link('Ajouter une société manuellement')
    fill_in "Nom de l'entreprise ou de l'administration", with: 'DADA ENTREPRISE'
    fill_in "Numéro et rue (allée, avenue, etc.)", with: '22 rue de Cotte'
    fill_in "Ville", with: 'Paris'
    fill_in "Code postal", with: '75012'
    find('label[for="organisation_is_public_true"]').click
    fill_in('Site web (optionnel)', with: 'https://www.ina.fr')
    find('input[type="submit"]').click
    find('span#alert-text', text: 'Les modifications sont enregistrées')
    organisation = organisation.reload
    assert_equal 'DADA ENTREPRISE', organisation.employer_name
    assert_equal 'MyString', organisation.group.name
    assert_equal 'https://www.ina.fr', organisation.employer_website
    # Siret is not compulsary
    assert_equal '22 rue de Cotte', organisation.street
    assert_equal '75012', organisation.zipcode
    assert_equal 'Paris', organisation.city
    internship_offer = internship_offer.reload
    assert_equal organisation.id, internship_offer.organisation.id
    assert_equal organisation.employer_name, internship_offer.employer_name
    assert_equal organisation.employer_website, internship_offer.employer_website
    assert_equal organisation.street, internship_offer.street
    assert_equal organisation.zipcode, internship_offer.zipcode
    assert_equal organisation.city, internship_offer.city
    assert_equal organisation.coordinates.longitude, internship_offer.coordinates.longitude
    assert_equal organisation.coordinates.latitude, internship_offer.coordinates.latitude
  end
end
