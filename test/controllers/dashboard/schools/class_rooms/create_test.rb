# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class CreateClassRoomsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # Create, SchoolManager
      #
      test 'POST class_rooms#create as SchoolManager responds with success' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)
        class_room_name = SecureRandom.hex
        assert_difference 'ClassRoom.count' do
          post dashboard_school_class_rooms_path(school.to_param), params: { class_room: { name: class_room_name } }
          assert_redirected_to dashboard_school_class_rooms_path(school)
        end
        assert_equal 1, ClassRoom.where(name: class_room_name).count
      end

      test 'POST class_rooms#create with other roles fail' do
        school = create(:school, :with_school_manager)
        [
          create(:student, school: school)
        ].each do |role|
          sign_in(role)
          post dashboard_school_class_rooms_path(school.to_param), params: { class_room: { name: 'test' } }
          assert_redirected_to root_path
        end
      end
    end
  end
end
