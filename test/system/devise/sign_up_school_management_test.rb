# frozen_string_literal: true

require 'application_system_test_case'

class SignUpSchoolManagersTest < ApplicationSystemTestCase
  test 'navigation & interaction works until school manager creation' do
    existing_email = 'ce.0750655E@ac-paris.fr'
    school_1 = create(:school, name: 'Etablissement Test 1', city: 'Saint-Martin')
    create(:student, email: existing_email)
    password = 'kikoololtest'
    # go to signup as school_manager
    visit new_user_registration_path(as: 'SchoolManagement')

    # fails to create school_manager with existing email
    assert_difference('Users::SchoolManagement.school_manager.count', 0) do
      find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Saint')
      find('#downshift-0-item-0').click
      select school_1.name, from: "user_school_id"
      select "Chef d'établissement", from: 'user_role'
      fill_in 'Prénom', with: 'Martin'
      find("input[name='user[last_name]']").fill_in with: 'Fourcade'
      fill_in 'Adresse électronique académique', with: existing_email # error
      fill_in 'Créer un mot de passe', with: password
      fill_in 'Ressaisir le mot de passe', with: password
      find('label[for="user_accept_terms"]').click
      click_on "Je m'inscris"
    end
    if ENV['RUN_BRITTLE_TEST'] && ENV['RUN_BRITTLE_TEST'] == 'true'
      # create school_manager
      school_nr = ((rand * 0.9 + 0.1) * 10_000_000).to_i
      assert_difference('Users::SchoolManagement.school_manager.count', 1) do
        fill_in 'Adresse électronique académique', with: "ce.#{school_nr}E@ac-paris.fr"
        fill_in 'Créer un mot de passe', with: password
        fill_in 'Ressaisir le mot de passe', with: password
        fill_in 'Prénom', with: 'Martin'
        find("input[name='user[last_name]']").fill_in with: 'Fourcade'
        click_on "Je m'inscris"
      end
    end
  end

  test 'navigation & interaction works until teacher creation' do
    school_1 = create(:school, name: 'Etablissement Test 1', city: 'Saint-Martin', zipcode: '77515')
    create(:school_manager, school: school_1)
    school_2 = create(:school, name: 'Etablissement Test 2', city: 'Saint-Parfait', zipcode: '77555')
    class_room_1 = create(:class_room, name: '3e A', school: school_1)
    class_room_2 = create(:class_room, name: '3e B', school: school_2)
    existing_email = 'fourcade.m@gmail.com'
    another_email = 'another@free.fr'

    # go to signup as teacher
    visit new_user_registration_path(as: 'SchoolManagement')

    # fails to create teacher with existing email
    assert_difference('Users::SchoolManagement.teacher.count', 0) do
      find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Saint')
      find('#downshift-0-item-1').click
      select school_2.name, from: "user_school_id"
      select 'Professeur', from: 'user_role'
      select(class_room_2.name, from: 'user_class_room_id')
      fill_in 'Prénom', with: 'Martin'
      find("input[name='user[last_name]']").fill_in with: 'Fourcade'
      fill_in 'Adresse électronique', with: existing_email
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      find('label[for="user_accept_terms"]').click
      click_on "Je m'inscris"
    end

    # ensure failure reset form as expected
    assert_equal school_2.city,
                 find_field('Nom (ou ville) de mon établissement').value,
                 're-select of city after failure fails'

    # create teacher
    assert_difference('Users::SchoolManagement.teacher.count', 1) do
      find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Saint')
      find('#downshift-0-item-0').click
      select school_1.name, from: "user_school_id"
      select(class_room_1.name, from: 'user_class_room_id')
      fill_in 'Adresse électronique', with: "another@#{school_1.email_domain_name}"
      fill_in 'Créer un mot de passe', with: 'kikoololletest'
      fill_in 'Ressaisir le mot de passe', with: 'kikoololletest'
      all('label[for="user_accept_terms"]')[1].click
      click_on "Je m'inscris"
    end

    # check created teacher has valid info
    created_teacher = Users::SchoolManagement.where(email: "another@#{school_1.email_domain_name}").first
    assert_equal school_1, created_teacher.school
    assert_equal class_room_1, created_teacher.class_room
    assert_equal 'Martin', created_teacher.first_name
    assert_equal 'Fourcade', created_teacher.last_name
  end
end
