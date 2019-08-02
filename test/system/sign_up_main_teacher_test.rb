# frozen_string_literal: true

require 'application_system_test_case'

class SignUpMainTeachersTest < ApplicationSystemTestCase
  test 'navigation & interaction works until main teacherr creation' do
    school_1 = create(:school, name: 'Collège Test 1', city: 'Saint-Martin')
    school_manager = create(:school_manager, school: school_1)
    school_2 = create(:school, name: 'Collège Test 2', city: 'Saint-Parfait')
    class_room_1 = create(:class_room, name: '3e A', school: school_1)
    class_room_2 = create(:class_room, name: '3e B', school: school_2)
    existing_email = 'fourcade.m@gmail.com'
    birth_date = 14.years.ago

    # go to signup as main teacher
    visit new_user_registration_path(as: 'MainTeacher')

    # fails to create main teacher with existing email
    assert_difference('Users::MainTeacher.count', 0) do
      find_field('Ville de mon collège').fill_in(with: 'Saint')
      all('.list-group a.list-group-item').last.click
      find("label[for=\"select-school-#{school_2.id}\"]").click

      fill_in 'Prénom', with: 'Martin'
      fill_in 'Nom', with: 'Fourcade'
      fill_in 'Adresse électronique', with: existing_email
      fill_in 'Choisir un mot de passe', with: 'kikoololletest'
      fill_in 'Confirmer le mot de passe', with: 'kikoololletest'
      click_on "Je m'inscris"
    end

    # ensure failure reset form as expected
    assert_equal school_2.city,
                 find_field('Ville de mon collège').value,
                 're-select of city after failure fails'

    # creates main teacher
    assert_difference('Users::MainTeacher.count', 1) do
      find_field('Ville de mon collège').fill_in(with: 'Saint')
      all('.list-group a.list-group-item').first.click
      find("label[for=\"select-school-#{school_1.id}\"]").click
      select(class_room_1.name, from: 'user_class_room_id')
      fill_in 'Adresse électronique', with: 'another@email.com'
      fill_in 'Choisir un mot de passe', with: 'kikoololletest'
      fill_in 'Confirmer le mot de passe', with: 'kikoololletest'
      click_on "Je m'inscris"
    end

    # check created main teacher has valid info
    created_main_teacher = Users::MainTeacher.where(email: 'another@email.com').first
    assert_equal school_1, created_main_teacher.school
    assert_equal class_room_1, created_main_teacher.class_room
    assert_equal 'Martin', created_main_teacher.first_name
    assert_equal 'Fourcade', created_main_teacher.last_name
  end
end
