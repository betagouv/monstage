# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class CreateClassRoomsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # Create, SchoolManagement
      #
      test 'POST class_rooms#create as SchoolManagement responds with success' do
        school = create(:school, :with_school_manager)

        [
          school.school_manager,
          create(:main_teacher, school: school),
          create(:other, school: school),
          create(:teacher, school: school)
        ].each do |role|
          sign_in(role)
          class_room_name = SecureRandom.hex
          assert_difference 'ClassRoom.count' do
            post dashboard_school_class_rooms_path(school.to_param), params: {
              class_room: {
                name: class_room_name
              }
            }
            assert_redirected_to dashboard_school_path(school)
          end
          assert_equal 1, ClassRoom.where(name: class_room_name).count
        end
      end

      test 'POST class_rooms#create with student roles fail' do
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
