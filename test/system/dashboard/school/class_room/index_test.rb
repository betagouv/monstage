require 'application_system_test_case'
module Dashboard
  class SchoolClassRoomIndexTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'modal raises once only' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)

      sign_in(school.school_manager)
      visit dashboard_school_class_rooms_path(school)

      find("h1#notice-school-manager-empty-weeks-title",
           text: "Renseignez les dates de stage de votre établissement" )
      
      visit edit_dashboard_school_path(school)
      visit dashboard_school_class_rooms_path(school)

      assert_select("h1#notice-school-manager-empty-weeks-title",
                    text: "Renseignez les dates de stage de votre établissement",
                    count: 0 )
    end
  end
end
