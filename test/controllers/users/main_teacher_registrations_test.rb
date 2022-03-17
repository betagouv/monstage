# frozen_string_literal: true

require 'test_helper'

class MainTeacherRegistrationsTest < ActionDispatch::IntegrationTest
  def assert_main_teacher_form_rendered
    assert_select 'input', value: 'SchoolManagement', hidden: 'hidden'
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Créer un mot de passe/
    assert_select 'label', /Ressaisir le mot de passe/
    assert_select 'label', /J'accepte les/
  end

  test 'GET new as a SchoolManagement renders expected inputs' do
    get new_user_registration_path(as: 'SchoolManagement')

    assert_response :success
    assert_main_teacher_form_rendered
  end

  test 'POST #create with missing params fails creation' do
    assert_difference('Users::SchoolManagement.main_teacher.count', 0) do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    type: 'Users::SchoolManagement',
                                                    first_name: 'Martin',
                                                    last_name: 'Fourcade' } })
      assert_response 200
      assert_main_teacher_form_rendered
    end
  end

  test 'POST #create with all params create MainTeacher' do
    school = create(:school)
    school_manager = create(:school_manager, school: school)
    class_room = create(:class_room, name: '3e A', school: school)
    assert_difference('Users::SchoolManagement.main_teacher.count', 1) do
      post user_registration_path(params: { user: { email: 'teacher@acu.edu.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    type: 'Users::SchoolManagement',
                                                    first_name: 'Martin',
                                                    last_name: 'Fourcade',
                                                    school_id: school.id,
                                                    class_room_id: class_room.id,
                                                    accept_terms: '1',
                                                    role: :main_teacher } })
      main_teacher_id =  Users::SchoolManagement.where(role: 'main_teacher').last.id                                          
      assert_redirected_to users_registrations_standby_path(id: main_teacher_id)
    end
  end
end
