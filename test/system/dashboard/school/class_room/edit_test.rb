require 'application_system_test_case'

module Dashboard
  class SchoolClassRoomEditTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'school manager can edit and update school name' do
      school = create(:school, :with_school_manager)
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
  end
end

