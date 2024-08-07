require 'application_system_test_case'

module Dashboard
  class SchoolClassRoomEditTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'school manager can edit and update school name' do
      school = create(:school, :with_weeks, :with_school_manager)
      class_room = create(:class_room, school: school, name: 'old name')

      sign_in(school.school_manager)
      new_class_room_name = 'wonder class_room'
      visit edit_dashboard_school_class_room_path(school, class_room)
      fill_in 'Nom de la classe', with: new_class_room_name
      click_button('Enregistrer')
      assert new_class_room_name, class_room.reload.name
    end

    test 'teacher can edit and update school weeks' do
      travel_to Date.new(2019, 9, 26) do
        now = Date.today
        unless (now.month == 5 && now.day > 25) || (now.month == 6 && now.day < 7)
          school = create(:school, :with_weeks, :with_school_manager)
          teacher = create(:teacher, school: school)

          sign_in(teacher)
          # new_class_room_name = 'wonder class_room'
          visit edit_dashboard_school_path(school)
          last_week_label = "Du 25 au 29 mai 2020"

          find('label', text:last_week_label).click
          click_button('Enregistrer les modifications')
          find("div[id='alert-success']")
          refute_equal last_week_label, school.weeks.last.select_text_method
          assert_equal last_week_label, DateRange.new(weeks: [school.reload.weeks.last])
                                                 .boundaries_as_string
                                                 .gsub('du ', 'Du ')
        end
      end
    end
  end
end
