require 'test_helper'

module Dashboard
  class SchoolsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def setup
      @school = create(:school)
    end

    #
    # Edit, SchoolManager
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
      assert_select "form a[href=?]", dashboard_school_class_rooms_path(@school)
    end


    #
    # Update, SchoolManager
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
        assert_redirected_to dashboard_school_class_rooms_path(@school)
        follow_redirect!
        assert_select "#alert-success #alert-text", {text: "Collège mis à jour avec succès"}, 1
      end
    end

    #
    # Show, SchoolManager
    #
    test 'GET show as Student is forbidden' do
      roles = [
        create(:student, school: @school),
        create(:school_manager, school: @school),
        create(:teacher, school: @school),
        create(:main_teacher, school: @school),
        create(:other, school: @school)
      ]
      roles.map do |role|
        sign_in(role)
        get dashboard_school_path(@school)
        assert_redirected_to root_path
      end
    end
  end
end
