require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'GET index not logged redirects to sign in' do
    get favorites_path
    assert_redirected_to user_session_path
  end

  test 'GET index when logged in it renders the page' do
    student = create(:student)
    sign_in(student)
    get favorites_path
    assert_response :success
  end

  test 'GET index when logged in it renders the user s favorites' do
    student = create(:student)
    other_student = create(:student)
    fav_1 = create(:favorite, user: student)
    fav_2 = create(:favorite, user: student)
    fav_3 = create(:favorite, user: other_student)
    sign_in(student)

    get favorites_path

    assert_response :success
    assert_equal student.favorites.count, 2
  end

  test 'GET index when logged in with no fav it renders the page' do
    student = create(:student)
    sign_in(student)

    get favorites_path

    assert_response :success
    assert_equal student.favorites.count, 0
  end

  test 'POST #create create a favorite' do
    student = create(:student)
    internship_offer = create(:weekly_internship_offer)
    sign_in(student)

    assert_difference('Favorite.count', 1) do
      post favorites_path(id: internship_offer.id)
    end
    
    assert_equal student.favorites.count, 1
    assert_equal student.favorites.last.internship_offer, internship_offer
  end 

  test 'DELETE #destroy delete a favorite' do
    student = create(:student)
    internship_offer = create(:weekly_internship_offer)
    favorite = create(:favorite, user: student, internship_offer: internship_offer)
    sign_in(student)

    assert_difference('Favorite.count', -1) do
      delete favorite_path(id: internship_offer.id)
    end
    
    assert_equal student.favorites.count, 0
    assert_equal student.favorites.last, nil
  end 
end
