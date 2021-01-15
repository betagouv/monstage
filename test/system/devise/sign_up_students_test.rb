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

  test 'navigation & interaction works until student creation with phone' do
    school_1 = create(:school, name: 'Etablissement Test 1', city: 'Saint-Martin', zipcode: '77515')
    school_2 = create(:school, name: 'Etablissement Test 2', city: 'Saint-Parfait', zipcode: '51577')
    class_room_1 = create(:class_room, name: '3e A', school: school_1)
    class_room_2 = create(:class_room, name: '3e B', school: school_2)
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
      # execute_script("document.getElementById('user_accept_terms').checked = true")
      find('label[for="user_accept_terms"]').click
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
