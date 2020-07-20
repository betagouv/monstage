# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class NewClassRoomsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # New, SchoolManagement
      #
      test 'GET class_rooms#new as SchoolManagement responds with success' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        class_room_name = SecureRandom.hex
        class_room = create(:class_room, name: class_room_name, school: school)
        sign_in(school_manager)

        get new_dashboard_school_class_room_path(school.to_param)

        assert_response :success
      end

      test 'GET class_rooms#new with other roles fail' do
        school = create(:school, :with_school_manager)
        [
          create(:student, school: school)
        ].each do |role|
          sign_in(role)
          get new_dashboard_school_class_room_path(school.to_param)
          assert_redirected_to root_path
        end
      end
    end
  end
end
