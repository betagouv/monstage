# frozen_string_literal: true

require 'application_system_test_case'

class ManageOrganisationsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include OrganisationFormFiller
  include StubsForApiGouvRequests

  setup do
    stub_gouv_api_requests
  end

  # CREATE

  test 'internship_offer creation process: it can create an organisation when no organisation exists' do
    employer = create(:employer)
    is_public = true
    group = create(:group, name: 'hello', is_public: is_public)
    organisation = create(:organisation) # not used since the employer
    sign_in(employer)
    assert_difference 'Organisation.count' do
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      fill_in_organisation_form(is_public: is_public, group: group)
      find('span.number', text: '1')
      find('span.number', text: '2')
      find('span.number', text: '3')
      click_on "Suivant"
    end
    organisation = Organisation.last
    assert_equal 'EAST SIDE SOFTWARE', organisation.employer_name
    assert_equal '18 RUE DE COTTE', organisation.street
    assert_equal 'PARIS 12', organisation.city
    assert_equal '75012', organisation.zipcode
    assert_equal '90943224700015', organisation.siret
    assert_equal Coordinates.paris_12[:longitude], organisation.coordinates.longitude
    assert_equal Coordinates.paris_12[:latitude], organisation.coordinates.latitude
    assert_equal 'hello', organisation.group.name
    assert_equal 'https://beta.gouv.fr/', organisation.employer_website
    find("h1.h2.mb-3", text: "Déposer une offre de stage")
  end

  test 'internship_offer creation process: it can create an organisation when at least one organisation exists' do
    # does the same as 'inside a list of organisations, it can create a new organisation'
    employer = create(:employer)
    is_public = true
    group = create(:group, name: 'hello', is_public: is_public)
    organisation = create(:organisation, employer_id: employer.id)
    sign_in(employer)
    assert_difference 'Organisation.count' do
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      find('a[href="/dashboard/stepper/organisations/new?checked_organisations_list=true"]').click
      fill_in_organisation_form(is_public: true, group: group)
      find('span.number', text: '1')
      find('span.number', text: '2')
      find('span.number', text: '3')
      click_on "Suivant"
    end
    assert_equal 2, Organisation.count
    organisation = Organisation.last
    assert_equal '18 RUE DE COTTE', organisation.street
    assert_equal 'PARIS 12', organisation.city
    assert_equal '75012', organisation.zipcode
    assert_equal Coordinates.paris_12[:longitude], organisation.coordinates.longitude
    assert_equal Coordinates.paris_12[:latitude], organisation.coordinates.latitude
    find("h1.h2.mb-3", text: "Déposer une offre de stage")
  end

  test 'internship_offer creation process: inside list of organisations, it can reuse an organisation' do
    employer = create(:employer)
    is_public = true
    group = create(:group, name: 'hello', is_public: is_public)
    organisation = create(:organisation, employer_id: employer.id)
    sign_in(employer)
    assert_no_difference 'Organisation.count' do
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      find("#reuse-organisation-btn-#{organisation.id}.fr-btn").click
      refute_selector('span.number', text: '1')
      find('span.number', text: '2')
      find('span.number', text: '3')
      find("h1.h2.mb-3", text: "Déposer une offre de stage")
      click_on "Suivant"
    end
    assert_equal 1, Organisation.count
    find("h1.h2.mb-3", text: "Déposer une offre de stage")
    find("label.fr-label[for='internship_offer_info_title']", text: "Intitulé du stage")
  end

  test 'internship_offer creation process: inside list of organisations, it can update an organisation' do
    employer = create(:employer)
    organisation = create(:organisation, employer_id: employer.id)
    sign_in(employer)
    assert_no_difference 'Organisation.count' do
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      find("#update-organisation-btn-#{organisation.id}.fr-btn").click
      find("h1.h2.mb-3", text: "Déposer une offre de stage - modifier les informations de siège")
      click_link('... ou faire une recherche')
      fill_in 'Rechercher votre société dans l’Annuaire des Entreprises', with: '90943224700015'
      within('.container-downshift') do
        within('ul') do
          all('li').first.click
        end
      end
      fill_in('Site web (optionnel)', with: 'https://www.ina.fr')
      find('button[type="submit"]').click
      assert_equal 1, Organisation.count
      find("h1.h2.mb-3", text: "Déposer une offre de stage")
      find("label.fr-label[for='internship_offer_info_title']", text: "Intitulé du stage")
    end
  end

  test 'internship_offer creation process: create organisation fails gracefuly' do
    employer = create(:employer)
    organisation = create(:organisation, employer_id: employer.id)
    sign_in(employer)
    assert_no_difference 'Organisation.count' do
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      find("#update-organisation-btn-#{organisation.id}.fr-btn").click
      find("h1.h2.mb-3", text: "Déposer une offre de stage - modifier les informations de siège")
      click_link('... ou faire une recherche')
      fill_in 'Rechercher votre société dans l’Annuaire des Entreprises', with: '90943224700015'
      within('.container-downshift') do
        within('ul') do
          all('li').first.click
        end
      end
      fill_in('Site web (optionnel)', with: 'https://www.ina.fr')
      as = 'a' * (InternshipOffer::EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT + 2)
      find('#organisation_employer_description_rich_text', visible: false).set(as)
      find('button[type="submit"]').click
      find('#error_explanation')
      assert page.has_content?('La description doit faire au maximum 250 caractères')
    end
  end




  # EDIT

  test 'internship_offer edition process: it can reuse an organisation' do
    internship_offer = create(:weekly_internship_offer)
    # created as such, internship_offer has no organisation set yet
    employer = internship_offer.employer
    organisation_2 = create(:organisation, employer_name: 'Gusto', city:'Tours', employer_id: employer.id)
    sign_in(employer)
    visit dashboard_internship_offer_path(internship_offer)
    click_on 'Modifier'

    organisation = internship_offer.reload.organisation
    internship_offer_info = internship_offer.internship_offer_info
    tutor = internship_offer.tutor

    refute organisation.nil?
    refute internship_offer_info.nil?
    refute tutor.nil?

    find('h1', text: 'Modifier une offre de stage')
    assert_css('.fr-tabs ul li button#tabpanel-headquarters')
    refute_css('.fr-tabs ul li button#tabpanel-internship')
    refute_css('.fr-tabs ul li button#tabpanel-tutor')
    find("#reuse-btn-organisation-#{organisation.id}.fr-btn").click

    click_link('... ou faire une recherche')
    assert_css('.fr-tabs ul li button#tabpanel-headquarters')
    assert_css('.fr-tabs ul li button#tabpanel-internship')
    assert_css('.fr-tabs ul li button#tabpanel-tutor')
    refute_selector('span.number', text: '1')
    refute_selector('span.number', text: '2')
    refute_selector('span.number', text: '3')

    organisation.reload
    assert_equal 'Octo', organisation.employer_name
    assert_equal 'https://www.ina.fr', organisation.employer_website

    assert_equal 'Octo', Organisation.order(updated_at: :desc).first.employer_name
    assert_equal 2, Organisation.count
    find("button#tabpanel-headquarters").click

    find("#reuse-btn-organisation-#{organisation_2.id}.fr-btn").click
    assert_equal 2, Organisation.count
    # assert_equal 'Tours' , internship_offer.reload.city
    assert_equal 'Gusto' , internship_offer.reload.employer_name
  end


  # test 'internship_offer edition process: it can edit an organisation when at least two organisations exist' do
  # end

  test 'internship_offer edition process: inside list of organisations - it can create a new organisation' do
    internship_offer = create( :weekly_internship_offer )
    # created as such, internship_offer has no organisation set yet
    employer = internship_offer.employer
    sign_in(employer)
    visit dashboard_internship_offer_path(internship_offer)
    click_on 'Modifier'

    organisation = internship_offer.reload.organisation
    internship_offer_info = internship_offer.internship_offer_info
    tutor = internship_offer.tutor

    refute organisation.nil?
    refute internship_offer_info.nil?
    refute tutor.nil?

    find('h1', text: 'Modifier une offre de stage')
    assert_css('.fr-tabs ul li button#tabpanel-headquarters')
    refute_css('.fr-tabs ul li button#tabpanel-internship')
    refute_css('.fr-tabs ul li button#tabpanel-tutor')
    find("#add-organisation-btn.fr-btn").click
    refute_selector('span.number', text: '1')
    refute_selector('span.number', text: '2')
    refute_selector('span.number', text: '3')
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

    # find('.fr-text--lg.fr-mb-2w', text: "Adresse de l'entreprise ou de l'administration")
    fill_in 'Rechercher votre société dans l’Annuaire des Entreprises', with: '90943224700015'
    within('.container-downshift') do
      within('ul') do
        all('li').first.click
      end
    end
    fill_in('Site web (optionnel)', with: 'https://www.ina.fr')
    find('button[type="submit"]').click
    find('span#alert-text', text: 'Vos informations sont enregistrées')
    assert_css('.fr-tabs ul li button#tabpanel-headquarters')
    assert_css('.fr-tabs ul li button#tabpanel-internship')
    assert_css('.fr-tabs ul li button#tabpanel-tutor')
  end

  # test 'internship_offer edition process: inside list of organisations - it can reuse an organisation' do
  # end

  test 'internship_offer edition process: inside list of organisations - it can update an organisation' do
    internship_offer = create( :weekly_internship_offer )
    # created as such, internship_offer has no organisation set yet
    employer = internship_offer.employer
    sign_in(employer)
    visit dashboard_internship_offer_path(internship_offer)
    click_on 'Modifier'

    organisation = internship_offer.reload.organisation
    internship_offer_info = internship_offer.internship_offer_info
    tutor = internship_offer.tutor

    refute organisation.nil?
    refute internship_offer_info.nil?
    refute tutor.nil?

    find('h1', text: 'Modifier une offre de stage')
    assert_css('.fr-tabs ul li button#tabpanel-headquarters')
    refute_css('.fr-tabs ul li button#tabpanel-internship')
    refute_css('.fr-tabs ul li button#tabpanel-tutor')
    find("#update-organisation-btn-#{organisation.id}.fr-btn").click
    refute_selector('span.number', text: '1')
    refute_selector('span.number', text: '2')
    refute_selector('span.number', text: '3')

    # find('.fr-text--lg.fr-mb-2w', text: "Adresse de l'entreprise ou de l'administration")
    click_link('... ou faire une recherche')
    refute_selector('span.number', text: '1')
    refute_selector('span.number', text: '2')
    refute_selector('span.number', text: '3')
    fill_in 'Rechercher votre société dans l’Annuaire des Entreprises', with: '90943224700015'
    within('.container-downshift') do
      within('ul') do
        all('li').first.click
      end
    end
    fill_in('Site web (optionnel)', with: 'https://www.ina.fr')
    find('button[type="submit"]').click
    find('span#alert-text', text: 'Les modifications sont enregistrées')
    refute_selector('span.number', text: '1')
    refute_selector('span.number', text: '2')
    refute_selector('span.number', text: '3')
    assert_css('.fr-tabs ul li button#tabpanel-headquarters')
    assert_css('.fr-tabs ul li button#tabpanel-internship')
    assert_css('.fr-tabs ul li button#tabpanel-tutor')
    organisation = organisation.reload
    assert_equal 'EAST SIDE SOFTWARE', organisation.employer_name
    assert_equal 'MyString', organisation.group.name
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
    find("#update-organisation-btn-#{organisation.id}.fr-btn").click
    find('h1', text: 'Modifier une offre de stage')
    within('#container-downshift-address') do
      find('.fr-text--lg.fr-mb-2w ', text: "Adresse de l'entreprise ou de l'administration")
    end
    click_link('... ou faire une recherche')
    refute_selector('span.number', text: '1')
    refute_selector('span.number', text: '2')
    refute_selector('span.number', text: '3')

    # Mistaking here
    fill_in 'Rechercher votre société dans l’Annuaire des Entreprises', with: ''

    select(Group.is_public.order(:name).second.name)
    fill_in('Site web (optionnel)', with: 'https://www.ina.fr')
    find('button[type="submit"]').click
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
    find("#update-organisation-btn-#{organisation.id}.fr-btn").click
    click_link('... ou faire une recherche')
    click_link('Ajouter une société manuellement')
    fill_in "Nom de l'entreprise ou de l'administration", with: 'DADA ENTREPRISE'
    fill_in "Numéro et rue (allée, avenue, etc.)", with: '22 rue de Cotte'
    fill_in "Ville", with: 'Paris'
    fill_in "Code postal", with: '75012'
    refute_selector('span.number', text: '1')
    refute_selector('span.number', text: '2')
    refute_selector('span.number', text: '3')
    find('label[for="organisation_is_public_true"]').click
    fill_in('Site web (optionnel)', with: 'https://www.ina.fr')
    find('button[type="submit"]').click
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
  end
end
