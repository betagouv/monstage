require 'test_helper'

class ClassRoomsControllerTest < ActionDispatch::IntegrationTest
  include SessionManagerTestHelper

  test 'GET new as SchoolManager responds with success' do
    school = create(:school)
    school_manager = create(:school_manager, school: school)
    class_room_name = SecureRandom.hex
    class_room = create(:class_room, name: class_room_name, school: school)
    sign_in(as: school_manager) do
      get new_class_room_path
      assert_select '.class-room-name', text: class_room_name
      assert_response :success
    end
  end

  test 'GET new as Student responds with fail' do
    sign_in(as: MockUser::Student) do
      get new_class_room_path
      assert_redirected_to root_path
    end
  end

  test 'POST create as SchoolManager responds with success' do
    school = create(:school)
    school_manager = create(:school_manager, school: school)
    sign_in(as: school_manager) do
      class_room_name = SecureRandom.hex
      assert_difference 'ClassRoom.count' do
        post class_rooms_path, params: { class_room: { name: class_room_name } }
        assert_redirected_to new_class_room_path
      end
      assert_equal 1, ClassRoom.where(name: class_room_name).count
    end
  end

  test 'POST create as Student responds with fail' do
    sign_in(as: MockUser::Student) do
      post class_rooms_path, params: { class_room: {name: 'test'} }
      assert_redirected_to root_path
    end
  end

  test 'GET edit as SchoolManager render form' do
    school = create(:school)
    school_manager = create(:school_manager, school: school)
    class_room = create(:class_room, school: school)

    sign_in(as: school_manager) do
      get edit_class_room_path(class_room)
      assert_response :success
    end
  end

  test 'PATCH update as SchoolManager update class_room' do
    school = create(:school)
    school_manager = create(:school_manager, school: school)
    class_room = create(:class_room, school: school, name: SecureRandom.hex)
    sign_in(as: school_manager) do
      patch class_room_path(class_room, params: {class_room: { name: 'new_name' }})
      assert_redirected_to new_class_room_path
      assert_equal 'new_name', class_room.reload.name
    end
  end
end
