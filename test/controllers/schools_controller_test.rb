require 'test_helper'

class SchoolInternshipWeeksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  def setup
    @school = create(:school)
  end

  test 'GET edit not logged redirects to sign in' do
    get edit_school_path(@school.to_param)
    assert_redirected_to user_session_path
  end

  test 'GET edit as Student redirects to root path' do
    sign_in(create(:student))
    get edit_school_path(@school.to_param)
    assert_redirected_to root_path
  end

  test 'GET edit as School Manager works redirects to sign in' do
    sign_in(create(:school_manager))
    get edit_school_path(@school.to_param)
    assert_response :success
  end

  test 'PATCH update not logged redirects to sign in' do
    patch(school_path(@school.to_param),
          params: {
            school: {
              weeks_ids:[ weeks(:week_2019_1).id, weeks(:week_2019_2).id ]
              }
            })
    assert_redirected_to user_session_path
  end

  test 'PATCH update as Student redirects to root path' do
    sign_in(create(:student))
    patch(school_path(@school.to_param),
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
      patch(school_path(@school.to_param),
            params: {
              school: {
                week_ids: weeks_ids
              }
            })
      assert_redirected_to account_edit_path
      follow_redirect!
      assert_select "#alert-success #alert-text", {text: "Collège mis à jour avec succès"}, 1
    end
  end
end
