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
      click_link('Editer')
      select('3e SEGPA', from: 'Filière')
      click_button('Enregistrer')
      assert 'troisieme_segpa', class_room.school_track
    end

    test 'teacher can edit and update school weeks' do
      now = Date.today
      unless (now.month == 5 && now.day > 25) || (now.month == 6 && now.day < 7)
        school = create(:school, :with_weeks, :with_school_manager)
        teacher = create(:teacher, school: school)

        sign_in(teacher)
        # new_class_room_name = 'wonder class_room'
        visit edit_dashboard_school_path(school)
        last_week_label = Week.selectable_on_school_year
                              .last
                              .select_text_method

        within('div[data-select-weeks-target="checkboxesContainer"]') do
          find('label', text: last_week_label).click
        end
        click_button('Enregistrer les modifications')
        find("div[id='alert-success']")
        refute_equal last_week_label, school.weeks.last.select_text_method
        assert_equal last_week_label, school.reload.weeks.last.select_text_method
      end
    end
  end
end

