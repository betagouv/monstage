# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class UpdateClassRoomsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # Update, SchoolManager
      #
      test 'PATCH class_rooms#update as SchoolManager update class_room' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school, name: SecureRandom.hex)
        sign_in(school.school_manager)
        patch dashboard_school_class_room_path(school, class_room, params: { class_room: { name: 'new_name' } })
        assert_redirected_to dashboard_school_class_rooms_path
        assert_equal 'new_name', class_room.reload.name
      end

      test 'PATCH class_rooms#update with other fails' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        [
          create(:student, school: school),
          create(:teacher, school: school),
          create(:main_teacher, school: school),
          create(:other, school: school)
        ].each do |role|
          sign_in(role)
          patch dashboard_school_class_room_path(school, class_room, params: { class_room: { name: 'new_name' } })
          assert_redirected_to root_path
        end
      end
    end
  end
end
