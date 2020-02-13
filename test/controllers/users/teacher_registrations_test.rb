# frozen_string_literal: true

require 'test_helper'

class TeacherRegistrationsTest < ActionDispatch::IntegrationTest
  def assert_teacher_form_rendered
    assert_select 'input', value: 'MainTeacher', hidden: 'hidden'
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Créer un mot de passe/
    assert_select 'label', /Ressaisir le mot de passe/
    assert_select '#test-accept-terms', /J'accepte les/
  end

  test 'GET new as a MainTeacher renders expected inputs' do
    get new_user_registration_path(as: 'Teacher')

    assert_response :success
    assert_teacher_form_rendered
  end

  test 'POST #create with missing params fails creation' do
    assert_difference('Users::Teacher.count', 0) do
      post user_registration_path(params: { user: { email: 'teacher@acu.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    type: 'Users::Teacher',
                                                    first_name: 'Martin',
                                                    last_name: 'Fourcade',
                                                    accept_terms: '1' } })
      assert_response 200
      assert_teacher_form_rendered
    end
  end

  test 'POST #create with all params create Teacher' do
    school = create(:school)
    school_manager = create(:school_manager, school: school)
    class_room = create(:class_room, name: '3e A', school: school)
    assert_difference('Users::Teacher.count', 1) do
      post user_registration_path(params: { user: { email: 'teacher@acu.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    type: 'Users::Teacher',
                                                    first_name: 'Martin',
                                                    last_name: 'Fourcade',
                                                    school_id: school.id,
                                                    class_room_id: class_room.id,
                                                    accept_terms: '1' } })
      assert_redirected_to users_registrations_standby_path(email: 'teacher@acu.fr')
    end
  end
end
