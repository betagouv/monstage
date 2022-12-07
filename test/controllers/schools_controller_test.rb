require "test_helper"

class SchoolsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'GET new not logged redirects to sign in' do
    get new_school_path
    assert_redirected_to user_session_path
  end

  test 'GET new not god redirects to root' do
    employer = create(:employer)
    sign_in(employer)
    get new_school_path
    assert_redirected_to root_path
  end

  test 'GET new when god it renders the page' do
    god = create(:god)
    sign_in(god)
    get new_school_path
    assert_response :success
  end

  test 'POST #create as god redirects to admin' do
    god = create(:god)
    sign_in(god)
    
    school_params = {
      name: 'Victor Hugo',
      code_uai: '1234567X',
      kind: 'rep',
      street:'1 rue de Rivoli',
      zipcode: '75001',
      city: 'Paris',
      visible: 1,
      coordinates: {
        latitude: 48.866667, 
        longitude: 2.333333
      }
    }

    assert_difference('School.count', 1) do
      post schools_path(school: school_params)
    end
    school = School.last
    assert_redirected_to rails_admin_path
    assert_equal school.name, 'Victor Hugo'
    assert_equal school.code_uai, '1234567X'
    assert_equal school.kind, 'rep'
    assert_equal school.street, '1 rue de Rivoli'
    assert_equal school.zipcode, '75001'
    assert_equal school.city, 'Paris'
    assert_equal school.visible, true
  end 
end
