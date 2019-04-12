require 'test_helper'

class AccountControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "GET index not logged redirects to sign in" do
    get account_path
    assert_redirected_to user_session_path
  end

  test "GET index as Student" do
    sign_in(create(:student))
    get account_path
    assert_template "users/edit"
    assert_template "dashboard/_student_navbar"
  end

  test "GET edit render :edit success with all roles" do
    school = create(:school)
    class_room_1 = create(:class_room, school: school)
    class_room_2 = create(:class_room, school: school)
    [
      create(:school_manager, school: school),
      create(:student),
      create(:main_teacher, school: school, class_room: class_room_1),
      create(:teacher, school: school, class_room: class_room_2),
      create(:other, school: school),
    ].each do |role|
      sign_in(role)
      get account_path
      assert_response :success, "#{role.type} should have access to edit himself"
      assert_select "form[action=?]", account_path(role)
    end
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
    assert_select "#alert-success #alert-text", {text: 'Compte mis à jour avec succès.'}, 1
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
    assert_select "#alert-success #alert-text", {text: 'Compte mis à jour avec succès.'}, 1
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
    assert_select "#alert-success #alert-text", {text: 'Compte mis à jour avec succès.'}, 1
  end

  test 'GET #edit can change email' do
    sign_in(create(:employer))
    get account_path

    assert_response :success
    assert_select "input#user_email[required]"
  end
end
