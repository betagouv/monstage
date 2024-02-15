# frozen_string_literal: true

require 'test_helper'

class StudentRegistrationsTest < ActionDispatch::IntegrationTest
  test 'GET new as Student renders expected inputs' do
    school = create(:school)
    class_room = create(:class_room, school: school)

    get new_identity_path
    assert_response :success
    assert_select 'input', value: 'Student', hidden: 'hidden'
    assert_select 'title', "Inscription élève - etape 1 sur 2 | Monstage"
    # jsx componentes do not show labels with the usual way
    assert_select 'label', /Nom/
    assert_select 'label', /Prénom/
    assert_select 'label', /Date de naissance/
    assert_select 'label', /Sexe/
  end

  test 'POST create Student with class responds with success' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    birth_date = 14.years.ago
    email = 'fourcade.m@gmail.com'
    assert_enqueued_jobs 2 do
      assert_enqueued_emails 1 do
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
                accept_terms: '1'
              }
            }
          )
          assert_redirected_to internship_offers_path
        end
      end
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
            email: '', # no email
            first_name: 'Jephthina' ,
            gender: 'f',
            last_name: "Théodore ",
            password: "[Filtered]",
            type: Users::Student.name
          }
        }
      )
      assert_response 200
    end
  end

  test 'reusing the same phone number while registrating leads to new sessions page' do
    phone = '+330611223344'
    create(:student, email: nil, phone: phone)

    birth_date = 14.years.ago
    assert_difference('Users::Student.count', 0) do
      post user_registration_path(
        params: {
          user: {
            accept_terms: 1,
            birth_date: birth_date,
            phone: phone,
            channel: 'phone',
            email: '',
            first_name: 'Jephthina',
            gender: 'f',
            last_name: "Théodore ",
            password: "[Filtered]",
            type: Users::Student.name
          }
        }
      )
      assert_redirected_to new_user_session_path(phone: phone)
    end
  end

  test 'POST create Student with entity responds with success' do
    identity = create(:identity_student_with_class_room_3e)
    email = 'ines@gmail.com'
    assert_difference('Users::Student.count') do
      post user_registration_path(
        params: {
          user: {
            type: 'Users::Student',
            identity_token: identity.token,
            email: email,
            password: 'okokok',
            accept_terms: '1'
          }
        }
      )
      assert_redirected_to internship_offers_path
    end
    created_student = Users::Student.first
    assert_equal identity.school_id, created_student.school.id
    assert_equal identity.class_room_id, created_student.class_room.id
    assert_equal identity.first_name, created_student.first_name
    assert_equal identity.last_name, created_student.last_name
    assert_equal identity.birth_date.year, created_student.birth_date.year
    assert_equal identity.birth_date.month, created_student.birth_date.month
    assert_equal identity.birth_date.day, created_student.birth_date.day
    assert_equal identity.gender, created_student.gender
    assert_equal email, created_student.email
  end

  test 'POST create Student w/o entity fails' do
    email = 'ines@gmail.com'
    assert_difference('Users::Student.count', 0) do
      post user_registration_path(
        params: {
          user: {
            type: 'Users::Student',
            email: email,
            password: 'okokok',
            accept_terms: '1'
          }
        }
      )
    end
  end
end
