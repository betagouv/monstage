# frozen_string_literal: true

require 'application_system_test_case'

class SignUpStudentsTest < ApplicationSystemTestCase
  # unfortunatelly on CI tests fails
  def safe_submit
    click_on "Je m'inscris"
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError
    execute_script("document.getElementById('new_user').submit()")
  end

  test 'navigation & interaction works until student creation' do
    school_1 = create(:school, name: 'Etablissement Test 1', city: 'Saint-Martin', zipcode: '77515')
    school_2 = create(:school, name: 'Etablissement Test 2', city: 'Saint-Parfait', zipcode: '51577')
    class_room_1 = create(:class_room, name: '3e A', school: school_1)
    class_room_2 = create(:class_room, name: '3e B', school: school_2)
    existing_email = 'fourcade.m@gmail.com'
    birth_date = 14.years.ago
    student = create(:student, email: existing_email)

    # go to signup as student
    visit new_user_registration_path(as: 'Student')

    # fails to create student with existing email and display email channel
    assert_difference('Users::Student.count', 0) do
      find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Saint')
      find('#downshift-0-item-0').click
      find("label[for=\"select-school-#{school_1.id}\"]").click
      select(class_room_1.name, from: 'user_class_room_id')
      fill_in 'Prénom', with: 'Martin'
      find("input[name='user[last_name]']").fill_in with: 'Fourcade'
      fill_in 'Date de naissance', with: birth_date.strftime('%d/%m/%Y')
      find('label', text: 'Masculin').click
      find('label', text: 'Email').click
      fill_in 'Adresse électronique', with: existing_email
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      find('label[for="user_accept_terms"]').click
      click_on "Je m'inscris"
      find('label', text: 'Un compte est déjà associé à cet email')
      assert_equal existing_email, find('#user_email').value
    end

    # ensure failure reset form as expected
    assert_equal school_1.city,
                 find_field('Nom (ou ville) de mon établissement').value,
                 're-select of city after failure fails'

    # create student
    assert_difference('Users::Student.count', 1) do
      find('label', text: 'Email').click
      fill_in 'Adresse électronique', with: 'another@email.com'
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      click_on "Je m'inscris"
    end

    # check created student has valid info
    created_student = Users::Student.where(email: 'another@email.com').first
    assert_equal school_1, created_student.school
    assert_equal class_room_1, created_student.class_room
    assert_equal 'Martin', created_student.first_name
    assert_equal 'Fourcade', created_student.last_name
    assert_equal birth_date.year, created_student.birth_date.year
    assert_equal birth_date.month, created_student.birth_date.month
    assert_equal birth_date.day, created_student.birth_date.day
    assert_equal 'm', created_student.gender
  end

  test 'class room is filters archived clas_rooms' do
    school_1 = create(:school, name: 'Etablissement Test 1', city: 'Saint-Martin', zipcode: '77515')
    class_room_0 = create(:class_room, name: '3e A', school: school_1)
    class_room_0.archive
    existing_email = 'fourcade.m@gmail.com'
    student = create(:student, email: existing_email)

    # go to signup as student
    visit new_user_registration_path(as: 'Student')

    # fails to find a class_room though there's an anonymized one
    find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Saint')
    find('#downshift-0-item-0').click
    find("label[for=\"select-school-#{school_1.id}\"]").click
    page.find("input[name='user[class_room_id]'][placeholder='Aucune classe disponible']")
  end

  test 'Student with mail subscription with former internship_offer ' \
       'visit leads to offer page even when mistaking along the way' do
    school_1 = create(:school, name: 'Etablissement Test 1',
                               city: 'Saint-Martin', zipcode: '77515')
    class_room_1 = create(:class_room, name: '3e A', school: school_1)
    birth_date = 14.years.ago
    email = 'yetanother@gmail.com'
    password = 'kikoololletest'
    offer = create(:weekly_internship_offer)

    visit internship_offer_path(offer)
    click_link 'Je postule'
    # below : 'Pas encore de compte ? Inscrivez-vous'
    find("a[class='text-danger font-weight-bold test-offer-id-#{offer.id}']").click

    assert "as=Student&user%5Btargeted_offer_id%5D=#{offer.id}",
           current_url.split('?').second

    # mistaking with password confirmation
    assert_difference('Users::Student.count', 0) do
      find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Saint')
      find('#downshift-0-item-0').click
      fill_in 'Prénom', with: 'Martine'
      find("input[name='user[last_name]']").fill_in with: 'Fourcadex'
      find('label', text: school_1.name).click
      fill_in 'Date de naissance', with: birth_date.strftime('%d/%m/%Y')
      find('label', text: 'Féminin').click
      find('label', text: 'Email').click
      fill_in 'Adresse électronique', with: email
      fill_in 'Créer un mot de passe', with: password

      fill_in 'Ressaisir le mot de passe', with: 'password'

      accept_terms = find('label[for="user_accept_terms"].custom-control-label')
      accept_terms.click
      click_on "Je m'inscris"
    end

    hidden_input = find('input[name="user[targeted_offer_id]"]', visible: false)
    assert_equal offer.id.to_s, hidden_input.value

    # real signup as student
    assert_difference('Users::Student.count', 1) do
      fill_in 'Date de naissance', with: birth_date.strftime('%d/%m/%Y')
      find('label[for="select-gender-boy"]', text: 'Masculin').click
      find('label[for="select-gender-girl"]', text: 'Féminin').click

      # fill_in 'Créer un mot de passe', with: ''
      fill_in 'Créer un mot de passe', with: password
      fill_in 'Ressaisir le mot de passe', with: password
      accept_terms = page.find('label[for="user_accept_terms"].custom-control-label')
      sleep 0.4
      accept_terms.click
      click_on "Je m'inscris"
    end

    created_student = Users::Student.find_by(email: email)

    # confirmation mail under the hood
    created_student.confirm
    created_student.reload
    assert created_student.confirmed?
    assert_equal offer.id, created_student.targeted_offer_id

    # visit login mail from confirmation mail
    visit new_user_session_path
    find('label', text: 'Email').click
    find("input[name='user[email]']").fill_in with: created_student.email
    find("input[name='user[password]']").fill_in with: password
    click_on 'Connexion'
    # redirected page is a show of targeted internship_offer
    assert_equal "/internship_offers/#{offer.id}", current_path
    # targeted offer id at student's level is now empty
    assert_nil created_student.reload.targeted_offer_id,
               'targeted offer should have been reset'
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

    click_link 'Je postule'
    # below : 'Pas encore de compte ? Inscrivez-vous'
    within('.onboarding-card.onboarding-card-sm') do
      click_link 'Me connecter'
    end
    # sign_in as Student
    find('label', text: 'Email').click
    find("input[name='user[email]']").fill_in with: student.email
    find("input[name='user[password]']").fill_in with: password
    click_on 'Connexion'

    # redirected page is a show of targeted internship_offer
    assert_equal "/internship_offers/#{offer.id}", current_path
    # targeted offer id at student's level is now empty
    assert_nil student.reload.targeted_offer_id,
               'targeted offer should have been reset'
  end

  test 'Student registered with phone logs in after visiting an internship_offer and lands on offer page' do
    password = 'kikoololletest'
    school_1 = create(:school, name: 'Etablissement Test 1',
                               city: 'Saint-Martin', zipcode: '77515')
    class_room_1 = create(:class_room, name: '3e A', school: school_1)
    student = create(:student, :registered_with_phone, school: school_1,
                                                       class_room: class_room_1, password: password)
    offer = create(:weekly_internship_offer)

    visit internship_offer_path(offer.id)

    click_link 'Je postule'
    # below : 'Pas encore de compte ? Inscrivez-vous'
    within('.onboarding-card.onboarding-card-sm') do
      click_link 'Me connecter'
    end
    # sign_in as Student
    find('label', text: 'Téléphone').click
    execute_script("document.getElementById('phone-input').value = '#{student.phone}';")
    find("input[name='user[password]']").fill_in with: password
    click_on 'Connexion'
    assert page.title.starts_with?('Offre de stage'),
           'Right after connexion, student should be connected to the offer show page'
    page.find('h2', text: 'Informations sur le stage')
    # redirected page is a show of targeted internship_offer
    assert_equal "/internship_offers/#{offer.id}", current_path
    # targeted offer id at student's level is now empty
    assert_nil student.reload.targeted_offer_id,
               'targeted offer should have been reset'
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
    click_link 'Postuler'
    # below : 'Pas encore de compte ? Inscrivez-vous'
    find("a[class='text-danger font-weight-bold test-offer-id-#{offer.id}']").click

    # signup as student
    assert_difference('Users::Student.count', 1) do
      find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Saint')
      find('#downshift-2-item-0').click
      find("label[for=\"select-school-#{school_1.id}\"]").click
      select(class_room_1.name, from: 'user_class_room_id')
      fill_in 'Prénom', with: 'Coufert'
      find("input[name='user[last_name]']").fill_in with: 'Darmarin'
      fill_in 'Date de naissance', with: birth_date.strftime('%d/%m/%Y')
      find('label', text: 'Masculin').click
      find('label', text: 'SMS').click
      execute_script("document.getElementById('phone-input').value = '#{valid_phone_number}';")
      fill_in 'Créer un mot de passe', with: password
      fill_in 'Ressaisir le mot de passe', with: password
      execute_script("document.getElementById('user_accept_terms').checked = true;")
      safe_submit
    end

    created_student = Users::Student.where(phone: valid_phone_number).first
    assert_equal offer.id, created_student.targeted_offer_id

    # confirmation mail under the hood
    created_student.confirm
    created_student.reload
    assert created_student.confirmed?
    # confirmation code step
    find('label', text: 'Code de confirmation').click
    find_field('Code de confirmation').fill_in(with: created_student.phone_token)
    click_on 'Valider'
    # visit login mail from confirmation mail
    find('label', text: 'Téléphone').click && sleep(0.6)
    execute_script("document.getElementById('phone-input').value = '#{valid_phone_number}';")
    find("input[name='user[password]']").fill_in with: password
    click_on 'Connexion'
    # redirected page is a show of targeted internship_offer
    assert_equal internship_offer_path(id: offer.id), current_path
    # targeted offer id at student's level is now empty
    assert_nil created_student.reload.targeted_offer_id,
               'targeted offer should have been reset'
  end

  test 'navigation & interaction works until student creation with phone' do
    school_1 = create(:school, name: 'Etablissement Test 1',
                               city: 'Saint-Martin', zipcode: '77515')
    school_2 = create(:school, name: 'Etablissement Test 2',
                               city: 'Saint-Parfait', zipcode: '51577')
    class_room_1 = create(:class_room, name: '3e A', school: school_1)
    create(:class_room, name: '3e B', school: school_2)
    existing_phone = '+330600110011'
    birth_date = 14.years.ago
    student = create(:student, phone: existing_phone)

    # go to signup as student
    visit new_user_registration_path(as: 'Student')

    # fails to create student with existing email
    assert_difference('Users::Student.count', 0) do
      find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Saint')
      find('#downshift-0-item-0').click
      find("label[for=\"select-school-#{school_1.id}\"]").click
      select(class_room_1.name, from: 'user_class_room_id')
      fill_in 'Prénom', with: 'Martin'
      find("input[name='user[last_name]']").fill_in with: 'Fourcade'
      fill_in 'Date de naissance', with: birth_date.strftime('%d/%m/%Y')
      find('label', text: 'Masculin').click
      find('label', text: 'SMS').click
      execute_script("document.getElementById('phone-input').value = '#{existing_phone}';")
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      execute_script("document.getElementById('user_accept_terms').checked = true;")
      safe_submit
    end

    # ensure failure reset form as expected
    assert_equal school_1.city,
                 find_field('Nom (ou ville) de mon établissement').value,
                 're-select of city after failure fails'

    # create student with phone
    assert_difference('Users::Student.count', 1) do
      execute_script("document.getElementById('phone-input').value = '+330637607756';")
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      safe_submit
    end
  end
end
