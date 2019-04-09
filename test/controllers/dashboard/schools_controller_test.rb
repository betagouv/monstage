require 'test_helper'

module Dashboard
  class SchoolsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def setup
      @school = create(:school)
    end

    #
    # Edit
    #
    test 'GET edit not logged redirects to sign in' do
      get edit_dashboard_school_path(@school.to_param)
      assert_redirected_to user_session_path
    end

    test 'GET edit as Student redirects to root path' do
      sign_in(create(:student))
      get edit_dashboard_school_path(@school.to_param)
      assert_redirected_to root_path
    end

    test 'GET edit as School Manager works' do
      school = create(:school)
      sign_in(create(:school_manager, school: school))

      get edit_dashboard_school_path(@school.to_param)

      assert_response :success
      assert_select "form a[href=?]", account_path
    end


    #
    # Update
    #
    test 'PATCH update not logged redirects to sign in' do
      patch(dashboard_school_path(@school.to_param),
            params: {
              school: {
                weeks_ids:[ weeks(:week_2019_1).id, weeks(:week_2019_2).id ]
                }
              })
      assert_redirected_to user_session_path
    end

    test 'PATCH update as Student redirects to root path' do
      sign_in(create(:student))
      patch(dashboard_school_path(@school.to_param),
            params: {
              school: {
                weeks_ids:[ weeks(:week_2019_1).id, weeks(:week_2019_2).id ]
              }
            })

      assert_redirected_to root_path
    end

    test 'PATCH update as SchoolManage update school' do
      sign_in(create(:school_manager, school: @school))
      weeks_ids = [ weeks(:week_2019_1).id, weeks(:week_2019_2).id]
      assert_difference('SchoolInternshipWeek.count', weeks_ids.size) do
        patch(dashboard_school_path(@school.to_param),
              params: {
                school: {
                  week_ids: weeks_ids
                }
              })
        assert_redirected_to account_path
        follow_redirect!
        assert_select "#alert-success #alert-text", {text: "Collège mis à jour avec succès"}, 1
      end
    end

    #
    # Show
    #
    test 'GET show as Student is forbidden' do
      sign_in(create(:student, school: @school))

      get dashboard_school_path(@school)
      assert_redirected_to root_path
    end

    test 'GET show as SchoolManager works' do
      sign_in(create(:school_manager, school: @school))

      get dashboard_school_path(@school)
      assert_response :success
    end

    test 'GET show as SchoolManager shows class rooms list' do
      class_rooms = [
        create(:class_room, school: @school),
        create(:class_room, school: @school),
        create(:class_room, school: @school)
      ]
      sign_in(create(:school_manager, school: @school))

      get dashboard_school_path(@school)
      class_rooms.map do |class_room|
        assert_select 'a[href=?]', dashboard_school_class_room_path(@school, class_room)
      end
    end

  end
end
