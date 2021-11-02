# frozen_string_literal: true

require 'test_helper'

class StudentRegistrationsTest < ActionDispatch::IntegrationTest
  test 'GET new as Student renders expected inputs' do
    school = create(:school)
    class_room = create(:class_room, school: school)

    get new_user_registration_path(as: 'Student')

    assert_response :success
    assert_select 'input', value: 'Student', hidden: 'hidden'

    assert_select 'title', "Inscription | Monstage"
    assert_select 'label', /Prénom/
    assert_select 'label', /Nom/
    assert_select 'label', /Date de naissance/
    assert_select 'div', /Sexe/
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Créer un mot de passe/
    assert_select 'label', /Ressaisir le mot de passe/
    assert_select 'div', /J'aurai besoin d'une aide adaptée pendant mon stage, en raison de mon handicap./
    assert_select 'label', /Indiquez ce dont vous avez besoin/
    assert_select 'label', /J'accepte les/
  end

  test 'POST Create Student without class fails' do
    assert_difference('Users::Student.count', 0) do
      post user_registration_path(params: {
                                    user: { email: 'fatou@snapchat.com',
                                            password: 'okokok',
                                            password_confirmation: 'okokok',
                                            first_name: 'Fatou',
                                            last_name: 'D',
                                            type: 'Users::Student',
                                            accept_terms: '1' }
                                  })
      assert_response 200
    end
  end

  test 'POST create Student with class responds with success' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    birth_date = 14.years.ago
    email = 'fourcade.m@gmail.com'
    assert_difference('Users::Student.count') do
      post user_registration_path(
        params: {
          user: {
            type: 'Users::Student',
            school_id: school.id,
            class_room_id: class_room.id,
            first_name: 'Martin',
            last_name: 'Fourcade',
            birth_date: birth_date,
            gender: 'np',
            email: 'fourcade.m@gmail.com',
            password: 'okokok',
            password_confirmation: 'okokok',
            handicap: 'cotorep',
            accept_terms: '1'
          }
        }
      )
      assert_redirected_to users_registrations_standby_path(email: email)
    end
    created_student = Users::Student.first
    assert_equal school, created_student.school
    assert_equal class_room, created_student.class_room
    assert_equal 'Martin', created_student.first_name
    assert_equal 'Fourcade', created_student.last_name
    assert_equal birth_date.year, created_student.birth_date.year
    assert_equal birth_date.month, created_student.birth_date.month
    assert_equal birth_date.day, created_student.birth_date.day
    assert_equal 'np', created_student.gender
    assert_equal 'fourcade.m@gmail.com', created_student.email
    assert_equal 'cotorep', created_student.handicap
  end

  test 'sentry#1885447470, registration with no js/html5 fails gracefully' do
    birth_date = 14.years.ago
    assert_difference('Users::Student.count', 0) do
      post user_registration_path(
          params: {
            user: {
              accept_terms: 1,
              birth_date: birth_date,
              channel: 'phone',
              email: '',
              first_name: 'Jephthina' ,
              gender: 'f',
              handicap: nil,
              handicap_present: 0,
              last_name: "Théodore ",
              password: "[Filtered]",
              password_confirmation: "[Filtered]",
              type: Users::Student.name
            }
          }
        )
        assert_response 200
    end
  end
end
