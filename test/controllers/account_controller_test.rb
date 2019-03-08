require 'test_helper'

class AccountControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "GET index not logged redirects to sign in" do
    get account_path
    assert_redirected_to user_session_path
  end

  test "GET index as Student" do
    sign_in(create(:student))
    get account_path

    assert_template "account/_edit_account_card"
  end

  test "GET index as SchoolManager" do
    sign_in(create(:school_manager))
    get account_path

    assert_template "account/_edit_account_card"
    assert_template "account/_edit_school_card"
    assert_template "account/_edit_school_class_rooms_card"
  end

  test "GET edit not logged redirects to sign in" do
    get account_edit_path

    assert_redirected_to user_session_path
  end

  test "GET edit as SchoolManager & Student render :edit" do
    [create(:school_manager), create(:student)].each do |role|
      sign_in(role)
      get account_edit_path
      assert_response :success, "#{role.type} should have access to edit himself"
    end
  end

  test "PATCH edit updates first_name, last_name and school_id" do
    [create(:school_manager), create(:student)].each do |current_role|
      sign_in(current_role)
      school = create(:school)

      patch account_path, params: { user: { school_id: school.id,
                                            first_name: 'Jules',
                                            last_name: 'Verne' } }

      assert_redirected_to account_path
      current_role.reload
      assert_equal school.id, current_role.school_id
      assert_equal 'Jules', current_role.first_name
      assert_equal 'Verne', current_role.last_name
      follow_redirect!
      assert_select "#alert-success #alert-text", {text: 'Compte mis à jour avec succès'}, 1
    end
  end
end
