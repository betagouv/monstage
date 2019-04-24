require 'test_helper'

class StudentRegistrationsTest < ActionDispatch::IntegrationTest
  test 'GET new as Student renders expected inputs' do
    school = create(:school)
    class_room = create(:class_room, school: school)

    get new_user_registration_path(as: 'Student')

    assert_response :success
    assert_select 'input', { value: 'Student', hidden: 'hidden' }

    assert_select 'label', /Ville de mon collège/
    assert_select 'label', /Collège/
    assert_select 'label', /Classe/
    assert_select 'label', /Prénom/
    assert_select 'label', /Nom/
    assert_select 'label', /Date de naissance/
    assert_select 'div', /Sexe/
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Choisir un mot de passe/
    assert_select 'label', /Confirmer le mot de passe/
  end

  test 'POST Create Student without class fails' do
    assert_difference("Users::Student.count", 0) do
      post user_registration_path(params: { user: { email: 'fatou@snapchat.com',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    first_name: 'Fatou',
                                                    last_name: 'D',
                                                    type: 'Users::Student' }})
      assert_response 200
    end
  end

  test 'POST create Student with class responds with success' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    birth_date = 14.years.ago
    assert_difference("Users::Student.count") do
      post user_registration_path(
        params: {
          user: {
            type: 'Users::Student',
            school_id: school.id,
            class_room_id: class_room.id,
            first_name: 'Martin',
            last_name: 'Fourcade',
            birth_date: birth_date,
            gender: 'm',
            email: 'fourcade.m@gmail.com',
            password: 'okokok',
            password_confirmation: 'okokok',
          }
        }
      )
      assert_redirected_to root_path
    end
    created_student = Users::Student.first
    assert_equal school, created_student.school
    assert_equal class_room, created_student.class_room
    assert_equal 'Martin', created_student.first_name
    assert_equal 'Fourcade', created_student.last_name
    assert_equal birth_date.year, created_student.birth_date.year
    assert_equal birth_date.month, created_student.birth_date.month
    assert_equal birth_date.day, created_student.birth_date.day
    assert_equal 'm', created_student.gender
    assert_equal 'fourcade.m@gmail.com', created_student.email
  end
end
