# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'GET index not logged redirects to sign in' do
    get account_path
    assert_redirected_to user_session_path
  end

  test 'GET index as Student' do
    student = create(:student)
    sign_in(student)
    get account_path
    assert_template 'users/edit'
    assert_template 'users/_edit_resume'
    assert_select 'form[action=?]', account_path
  end

  test 'GET index as Operator' do
    operator = create(:user_operator)
    sign_in(operator)
    get account_path
    assert_select 'a[href=?]', account_path(section: 'api')
  end

  test 'GET account_path(section: api) as Operator' do
    operator = create(:user_operator)
    sign_in(operator)
    get account_path(section: 'api')
    assert_select "a[href='#{account_path(section: 'api')}']"
    assert_select 'input[name="user[api_token]"]'
    assert_select "input[value=\"#{operator.api_token}\"]"
  end

  test 'GET account_path(section: identity) as Operator' do
    operator = create(:user_operator)
    sign_in(operator)
    get account_path(section: 'identity')
    assert_select "a[href='#{account_path(section: 'api')}']"
    assert_select 'select[name="user[department_name]"]'
  end

  test 'GET account_path(section: :school) as SchoolManagement' do
    school = create(:school, :with_school_manager)
    [
      school.school_manager,
      create(:main_teacher, school: school),
      create(:teacher, school: school),
      create(:other, school: school)
    ].each do |role|
      sign_in(role)
      get account_path(section: 'school')
      assert_select 'div[data-react-class="SearchSchool"]'
    end
  end

  test 'GET account_path(section: :identiy) as SchoolManagement can change identity' do
    school = create(:school, :with_school_manager)
    [
      school.school_manager,
      create(:main_teacher, school: school),
      create(:teacher, school: school),
      create(:other, school: school)
    ].each do |role|
      sign_in(role)
      get account_path(section: 'identity')
      assert_template 'users/_edit_identity'
      assert_select 'select[name="user[role]"]'
    end
  end

  test 'No other role than operator should have an API token' do
    student = create(:student)
    sign_in(student)
    get account_path
    assert_select "a[href='#{account_path(section: 'api')}']", false
  end

  test 'GET edit render :edit success with all roles' do
    school = create(:school)
    class_room_1 = create(:class_room, school: school)
    class_room_2 = create(:class_room, school: school)
    [
      create(:school_manager, school: school),
      create(:student),
      create(:main_teacher, school: school, class_room: class_room_1),
      create(:teacher, school: school, class_room: class_room_2),
      create(:other, school: school)
    ].each do |role|
      sign_in(role)
      get account_path(section: 'identity')
      assert_response :success, "#{role.type} should have access to edit himself"
      assert_template 'users/_edit_identity'
      assert_select 'form[action=?]', account_path
    end
  end

  test 'GET edit render as student also allow him to change class_room' do
    school = create(:school)
    class_room_1 = create(:class_room, school: school)
    class_room_2 = create(:class_room, school: school)
    student = create(:student, school: school, class_room: class_room_1)

    sign_in(student)
    get account_path(section: 'identity')

    assert_select 'select[name="user[class_room_id]"]'
  end

  test 'GET edit render as Statistician shows a readonly input on email' do
    statistician = create(:statistician)

    sign_in(statistician)
    get account_path(section: 'identity')

    assert_select 'input[name="user[email]"][readonly="readonly"]'
  end

  test 'PATCH edit as student, updates resume params' do
    student = create(:student)
    sign_in(student)

    patch(account_path, params: {
            user: {
              resume_educational_background: 'background',
              resume_other: 'other',
              resume_languages: 'languages',
              phone: '+330665656540'
            }
          })

    assert_redirected_to account_path
    student.reload
    assert_equal 'background', student.resume_educational_background.to_plain_text
    assert_equal 'other', student.resume_other.to_plain_text
    assert_equal 'languages', student.resume_languages.to_plain_text
    assert_equal '+330665656540', student.phone
    follow_redirect!
    assert_select '#alert-success #alert-text', { text: 'Compte mis à jour avec succès.' }, 1
  end

  test 'PATCH failures does not crashes' do
    student = create(:student)
    student_1 = create(:student, email: 'fourcade.m@gmail.com')

    sign_in(student)

    patch(account_path, params: {
            user: {
              email: student_1.email,
            }
          })

    assert_response :bad_request
  end

  test 'PATCH edit as school_manager, can change school' do
    original_school = create(:school)
    school_manager = create(:school_manager, school: original_school)
    sign_in(school_manager)

    school = create(:school)

    patch account_path, params: { user: { school_id: school.id,
                                          first_name: 'Jules',
                                          last_name: 'Verne' } }

    assert_redirected_to account_path
    school_manager.reload
    assert_equal school.id, school_manager.school_id
    assert_equal 'Jules', school_manager.first_name
    assert_equal 'Verne', school_manager.last_name
    follow_redirect!
    assert_select '#alert-success #alert-text', { text: 'Compte mis à jour avec succès.' }, 1
  end

  test 'PATCH edit as student can change class_room_id' do
    school = create(:school)
    student = create(:student, school: school)
    class_room = create(:class_room, school: school)
    sign_in(student)

    patch account_path, params: { user: { school_id: school.id,
                                          class_room_id: class_room.id,
                                          first_name: 'Jules',
                                          last_name: 'Verne' } }

    assert_redirected_to account_path
    student.reload
    assert_equal class_room.id, student.class_room_id
    follow_redirect!
    assert_select '#alert-success #alert-text', { text: 'Compte mis à jour avec succès.' }, 1
  end

  test 'PATCH edit as SchoolManagement can change role' do
    school = create(:school, :with_school_manager)
    users = [
      school.school_manager,
      create(:main_teacher, school: school),
      create(:teacher, school: school),
      create(:other, school: school)
    ]
    users.each.with_index do |user_change_role, i|
      sign_in(user_change_role)
      role_before = user_change_role.role
      role_after = (users[i + 1] || users[0]).role

      assert_changes -> { user_change_role.reload.role },
                     from: role_before,
                     to: role_after do
        patch(account_path, params: { user: { role: role_after } })
      end
    end
  end

  test 'PATCH edit as student can change missing_school_weeks_id' do
    school = create(:school)
    student = create(:student, school: school)
    sign_in(student)

    patch(account_path, params: { user: { missing_school_weeks_id: school.id } })

    assert_redirected_to account_path
    student.reload
    assert_equal student.school_id, student.missing_school_weeks_id
    follow_redirect!
    expected_custom_flash_message = "Nous allons prévenir votre chef d'établissement pour que vous puissiez postuler"
    assert_select('#alert-text',
                  text: expected_custom_flash_message)
  end

  test 'PATCH edit as Operator can change department_name' do
    user_operator = create(:user_operator)
    sign_in(user_operator)

    patch account_path, params: { user: { department_name: 60 } }

    assert_redirected_to account_path
    user_operator.reload
    assert_equal 60.to_s, user_operator.department_name
  end

  test 'PATCH edit as main_teacher can change class_room_id' do
    school = create(:school)
    school_manager = create(:school_manager, school: school)
    main_teacher = create(:main_teacher, school: school)
    class_room = create(:class_room, school: school)
    sign_in(main_teacher)

    patch account_path, params: { user: { class_room_id: class_room.id } }

    assert_redirected_to account_path
    main_teacher.reload
    assert_equal class_room.id, main_teacher.class_room_id
    follow_redirect!
    assert_select '#alert-success #alert-text', { text: 'Compte mis à jour avec succès.' }, 1
  end

  test 'GET #edit as Employer can change email' do
    sign_in(create(:employer))
    get account_path

    assert_response :success
    assert_select 'input#user_email[required]'
  end
end
