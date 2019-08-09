# frozen_string_literal: true

require 'application_system_test_case'

class SignUpTeachersTest < ApplicationSystemTestCase
  test 'navigation & interaction works until teacher creation' do
    school_1 = create(:school, name: 'Collège Test 1', city: 'Saint-Martin', zipcode: '77515')
    school_manager = create(:school_manager, school: school_1)
    school_2 = create(:school, name: 'Collège Test 2', city: 'Saint-Parfait', zipcode: '77555')
    class_room_1 = create(:class_room, name: '3e A', school: school_1)
    class_room_2 = create(:class_room, name: '3e B', school: school_2)
    existing_email = 'fourcade.m@gmail.com'

    # go to signup as teacher
    visit new_user_registration_path(as: 'Teacher')

    # fails to create teacher with existing email
    assert_difference('Users::Teacher.count', 0) do
      find_field('Ville de mon collège').fill_in(with: 'Saint')
      all('.list-group button.list-group-item').last.click
      find("label[for=\"select-school-#{school_2.id}\"]").click
      select(class_room_2.name, from: 'user_class_room_id')
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

    # create teacher
    assert_difference('Users::Teacher.count', 1) do
      find_field('Ville de mon collège').fill_in(with: 'Saint')
      all('.list-group button.list-group-item').first.click
      find("label[for=\"select-school-#{school_1.id}\"]").click
      select(class_room_1.name, from: 'user_class_room_id')
      fill_in 'Adresse électronique', with: 'another@email.com'
      fill_in 'Choisir un mot de passe', with: 'kikoololletest'
      fill_in 'Confirmer le mot de passe', with: 'kikoololletest'
      click_on "Je m'inscris"
    end

    # check created teacher has valid info
    created_teacher = Users::Teacher.where(email: 'another@email.com').first
    assert_equal school_1, created_teacher.school
    assert_equal class_room_1, created_teacher.class_room
    assert_equal 'Martin', created_teacher.first_name
    assert_equal 'Fourcade', created_teacher.last_name
  end
end
