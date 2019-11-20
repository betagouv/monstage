# frozen_string_literal: true

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
      assert_select 'form[action=?]', dashboard_school_path(@school)
      available_weeks = Week.selectable_on_school_year
      asserted_input_count = 0
      available_weeks.each do |week|
        assert_select "input[id=school_week_ids_#{week.id}]"
        asserted_input_count += 1
      end
      assert asserted_input_count > 0
    end

    test 'GET edit as God works' do
      school = create(:school)
      sign_in(create(:god))

      get edit_dashboard_school_path(@school.to_param)

      assert_response :success
      assert_select 'form[action=?]', dashboard_school_path(@school)
      assert_select 'input[name="school[name]"]'
      assert_select 'input[name="school[coordinates][longitude]"]'
      assert_select 'input[name="school[coordinates][latitude]"]'
    end

    #
    # Update as Student, SchoolManager & God
    #
    test 'PATCH update not logged redirects to sign in' do
      patch(dashboard_school_path(@school.to_param),
            params: {
              school: {
                weeks_ids: [weeks(:week_2019_1).id, weeks(:week_2019_2).id]
              }
            })
      assert_redirected_to user_session_path
    end

    test 'PATCH update as Student redirects to root path' do
      sign_in(create(:student))
      patch(dashboard_school_path(@school.to_param),
            params: {
              school: {
                weeks_ids: [weeks(:week_2019_1).id, weeks(:week_2019_2).id]
              }
            })

      assert_redirected_to root_path
    end

    test 'PATCH update as SchoolManager update school & redirect to class rooms' do
      sign_in(create(:school_manager, school: @school))
      weeks_ids = [weeks(:week_2019_1).id, weeks(:week_2019_2).id]
      assert_difference('SchoolInternshipWeek.count', weeks_ids.size) do
        patch(dashboard_school_path(@school.to_param),
              params: {
                school: {
                  week_ids: weeks_ids
                }
              })
        assert_redirected_to dashboard_school_class_rooms_path(@school)
        follow_redirect!
        assert_select '#alert-success #alert-text', { text: 'Collège mis à jour avec succès' }, 1
      end
    end

    test 'PATCH update as God update school & redirect to school list with anchor' do
      sign_in(create(:god))
      weeks_ids = [weeks(:week_2019_1).id, weeks(:week_2019_2).id]
      assert_difference('SchoolInternshipWeek.count', weeks_ids.size) do
        patch(dashboard_school_path(@school.to_param),
              params: {
                school: {
                  name: 'hello',
                  visible: false,
                  week_ids: weeks_ids
                }
              })
        assert_redirected_to dashboard_schools_path(anchor: "school_#{@school.id}")
        follow_redirect!
        assert_select '#alert-success #alert-text', { text: 'Collège mis à jour avec succès' }, 1
        @school.reload
        assert_equal 'hello', @school.name
        assert_equal false, @school.visible
      end
    end

    test 'PATCH update with missing params fails gracefuly' do
      sign_in(create(:school_manager, school: @school))
      patch(dashboard_school_path(@school.to_param), params: {})
      assert_response :unprocessable_entity
    end
  end
end
