# frozen_string_literal: true

require 'application_system_test_case'

class SignUpStudentsTest < ApplicationSystemTestCase
  # unfortunatelly on CI tests fails
  include ActiveJob::TestHelper

  def safe_submit
    click_on "Valider"
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError
    execute_script("document.getElementById('new_user').submit()")
  end

  test 'simple default radio button status' do
    identity = create(:identity)
    visit new_user_registration_path(as: 'Student', identity_token: identity.token)
    fill_in 'Adresse électronique', with: 'email@free.fr'
    assert find("#select-channel-email", visible: false).selected?
    find("#select-channel-phone", visible: false)

    find('label', text: 'Par téléphone').click

    fill_in 'Numéro de téléphone', with: '0623042525'
    assert find("#select-channel-phone", visible: false).selected?
    find("#select-channel-email", visible: false)
  end


  test 'navigation & interaction works until student creation' do
    school_1 = create(:school, name: 'Etablissement Test 1', city: 'Saint-Martin', zipcode: '77515')
    school_2 = create(:school, name: 'Etablissement Test 2', city: 'Saint-Parfait', zipcode: '51577')
    class_room_1 = create(:class_room, name: '3e A', school: school_1)
    class_room_2 = create(:class_room, name: '3e B', school: school_2)
    existing_email = 'fourcade.m@gmail.com'
    birth_date = 14.years.ago
    student = create(:student, email: existing_email)
    identity = create(:identity)

    # go to signup as student STEP 2
    visit new_user_registration_path(as: 'Student', identity_token: identity.token)

    # fails to create student with existing email and display email channel
    assert_difference('Users::Student.count', 0) do
      find("label[for='select-channel-email']",).click
      fill_in 'Adresse électronique', with: existing_email
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      click_on "Valider"
      find('.fr-alert.fr-alert--error', text: 'Courriel : Un compte est déjà associé à cet email')
      assert_equal existing_email, find('#user_email').value
    end

    # create student
    assert_difference('Users::Student.count', 1) do
      find('label', text: 'Par email').click
      fill_in 'Adresse électronique', with: 'another@email.com'
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      click_on "Valider"
    end
    # students are confirmed by default and redirected to search page after signup
    assert Users::Student.last.confirmed?
    find("h2 .strong", text: "0 Offre de stage")
    assert_select '#alert-text', count: 0
  end

  test 'select other class room' do
    school_1 = create(:school, name: 'Etablissement Test 1', city: 'Saint-Martin', zipcode: '77515')
    class_room_0 = create(:class_room, name: '3e A', school: school_1)
    existing_email = 'fourcade.m@gmail.com'
    student = create(:student, email: existing_email)

    # go to signup as student Step 1
    visit new_identity_path(as: 'Student')

    # fails to find a class_room though there's an anonymized one
    find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Saint')
    find('#downshift-0-item-0').click
    # find("label[for=\"select-school-#{school_1.id}\"]").click
    select school_1.name, from: "identity_school_id"
    select("Autre classe", from: 'identity_class_room_id')
  end

  test 'Student with mail subscription with former internship_offer ' \
       'visit leads to offer page even when mistaking along the way' do
    travel_to  Date.new(2020, 1, 1) do

      school_1 = create(:school, name: 'Etablissement Test 1',
                                city: 'Saint-Martin', zipcode: '77515')
      class_room_1 = create(:class_room, name: '3e A', school: school_1)
      birth_date = 14.years.ago
      email = 'yetanother@gmail.com'
      password = 'kikoololletest'
      offer = create(:weekly_internship_offer)

      visit internship_offer_path(offer)
      first(:link, 'Postuler').click
      find('a.fr-btn--secondary', text: "Créer un compte").click

      # mistaking with password confirmation
      assert_difference('Users::Student.count', 0) do
        sleep 0.3
        find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Saint')
        find('#downshift-0-item-0').click
        fill_in 'Prénom', with: 'Martine'
        fill_in 'Nom', with: 'Fourcadex'
        select school_1.name, from: "identity_school_id"
        fill_in 'Date de naissance', with: birth_date.strftime('%d/%m/%Y')
        find('label', text: 'Féminin').click

        click_on "Valider"
      end

      # real signup as student
      assert_difference('Users::Student.count', 1) do
        fill_in 'Adresse électronique', with: email, wait: 4
        fill_in 'Créer un mot de passe', with: password, wait: 4
        sleep 0.2
        find("input[type='submit']").click
      end

      created_student = Users::Student.find_by(email: email)

      # confirmation mail under the hood
      assert created_student.confirmed?
    end
  end

  test 'Student with account and former internship offer visit lands on offer page after login' do
    password = 'kikoololletest'
    school_1 = create(:school, name: 'Etablissement Test 1',
                               city: 'Saint-Martin', zipcode: '77515')
    class_room_1 = create(:class_room, name: '3e A', school: school_1)
    student = create(:student, school: school_1, class_room: class_room_1,
                               password: password)
    offer = create(:weekly_internship_offer)

    visit internship_offer_path(offer.id)

    first(:link, 'Postuler').click
    # below : 'Pas encore de compte ? Inscrivez-vous'
    # within('.onboarding-card.onboarding-card-sm') do
    #   click_link 'Me connecter'
    # end

    # TO DO FIX TEST
    #

    # sign_in as Student STEP 1



    # sign_in as Student STEP 2
    # find('label', text: 'Par email').click
    # find("input[name='user[email]']").fill_in with: student.email
    # find('label', text: 'Mot de passe').click
    # find("input[name='user[password]']").fill_in with: password
    # find("input[type='submit'][value='Connexion']").click
    # redirected page is a show of targeted internship_offer
    # assert_equal "/internship_offers/#{offer.id}/internship_applications/new", current_path
    # targeted offer id at student's level is now empty
    # assert_nil student.reload.targeted_offer_id,
    #            'targeted offer should have been reset'
  end

  test 'Student registered with phone logs in after visiting an internship_offer and lands on offer page' do
    travel_to Date.new(2020, 1, 1) do
      password = 'kikoololletest'
      weeks = Week.selectable_from_now_until_end_of_school_year.last(2)
      school_1 = create(:school, name: 'Etablissement Test 1',
                                city: 'Saint-Martin', zipcode: '77515',
                                weeks: weeks )
      class_room_1 = create(:class_room, name: '3e A', school: school_1)
      student = create(:student, :registered_with_phone, school: school_1,
                                                        class_room: class_room_1, password: password)
      offer = create(:weekly_internship_offer, weeks: weeks)

      visit internship_offer_path(offer.id)

      first(:link, 'Postuler').click
      find('label', text: 'Par téléphone').click
      execute_script("document.getElementById('phone-input').value = '#{student.phone}';")
      find("input[name='user[password]']").fill_in with: password
      find("input[type='submit'][value='Se connecter']").click
      page.find('h1', text: 'Votre candidature')
      # redirected page is a show of targeted internship_offer
      assert_equal "/offres-de-stage/#{offer.id}/candidatures/nouveau", current_path
      # targeted offer id at student's level is now empty
      # assert_nil student.reload.targeted_offer_id,
      #            'targeted offer should have been reset'
    end
  end

  test 'Student with phone subscription with former internship_offer choice leads to offer page' do
    school_1 = create(:school, name: 'Etablissement Test 1',
                               city: 'Saint-Martin', zipcode: '77515')
    class_room_1 = create(:class_room, name: '3e A', school: school_1)
    birth_date = 14.years.ago
    password = 'kikoololletest'
    valid_phone_number = '+330637607756'
    offer = create(:weekly_internship_offer)

    visit internship_offers_path
    find('h4 a', text: offer.title).click
    find('.sticky-top a[data-turbo="false"]', text: 'Postuler').click
    click_link 'Créer mon compte'

    # below : 'Pas encore de compte ? Inscrivez-vous'
    # click_on(class: 'text-danger') /!\ do not work
    visit users_choose_profile_path
    find('a[href="/identites/nouveau?as=Student"]').click

    assert Identity.count.zero?
    assert_difference('Users::Student.count', 1) do
      # signup as student - Identity creation
      find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Saint')
      find('#downshift-0-item-0').click
      select(school_1.name, from: "identity_school_id")
      select(class_room_1.name, from: 'identity_class_room_id')
      fill_in 'Prénom', with: 'Coufert'
      fill_in 'Nom', with: 'Darmarin'
      fill_in 'Date de naissance', with: birth_date.strftime('%d/%m/%Y')
      find('label', text: 'Masculin').click
      find('input[type="submit"]').click
      # 2nd page
      find('label[for="select-channel-phone"]').click
      execute_script("document.querySelector('div[data-signup-target=\"phoneBloc\"]').classList.remove('d-none')")
      execute_script("document.getElementById('phone-input').value = '#{valid_phone_number}';")
      fill_in 'Créer un mot de passe', with: password
      find('input[type="submit"]').click
      assert Identity.count.positive?
    end
    find('h4 a', text: offer.title)
  end

  test 'navigation & interaction works until student creation with phone' do
    travel_to Date.new(2020, 1, 1) do
      school_1 = create(:school, name: 'Etablissement Test 1',
                               city: 'Saint-Martin', zipcode: '77515')
      school_2 = create(:school, name: 'Etablissement Test 2',
                                city: 'Saint-Parfait', zipcode: '51577')
      class_room_1 = create(:class_room, name: '3e A', school: school_1)
      create(:class_room, name: '3e B', school: school_2)
      existing_phone = '+330600110011'
      birth_date = Date.new(2009, 1, 1)
      student = create(:student, phone: existing_phone)

      # go to signup as student STEP 1
      visit new_identity_path(as: 'Student')

      # fails to create student with existing email
      assert_difference('Users::Student.count', 0) do
        find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Saint')
        find('#downshift-0-item-0').click
        select school_1.name, from: "identity_school_id"
        select(class_room_1.name, from: 'identity_class_room_id')
        fill_in 'Prénom', with: 'Martin'
        fill_in 'Nom', with: 'Fourcade'
        fill_in 'Date de naissance', with: birth_date.strftime('%d/%m/%Y')
        find('label', text: 'Masculin').click
        click_on "Valider"

        find('label', text: 'Par téléphone').click
        execute_script("document.getElementById('phone-input').value = '#{existing_phone}';")
        fill_in 'Créer un mot de passe', with: 'kikoololletest'
        safe_submit
      end

      # ensure failure drives user to login_page
      find('span#alert-text', text: "Un compte est déjà associé à ce numéro de téléphone, connectez-vous ou réinitialisez votre mot de passe si vous l'avez oublié")
      # TODO functional is not ok
      assert_equal '+33 06 00 11 00 11', find("input[name='user[phone]']").value
    end
  end
end
