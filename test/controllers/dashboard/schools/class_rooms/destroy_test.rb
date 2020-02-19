# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class DestroyClassRoomsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # Edit, SchoolManager
      #
      test 'GET class_rooms#edit as SchoolManager render form' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)

        sign_in(school.school_manager)
        assert_changes -> { ClassRoom.count }, -1 do
          delete dashboard_school_class_room_path(school.to_param, class_room.to_param)
          assert_redirected_to dashboard_school_class_rooms_path(school)
        end
      end

      test 'GET class_rooms#edit with other roles fails' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        [
          create(:student, school: school, class_room: class_room)
        ].each do |role|
          sign_in(role)
          delete dashboard_school_class_room_path(school.to_param, class_room.to_param)
          assert_redirected_to root_path
        end
      end
    end
  end
end
