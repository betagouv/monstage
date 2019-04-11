require 'test_helper'

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @feedback = create(:feedback)
  end

  test "should get index as god" do
    sign_in(create(:god))
    get feedbacks_url
    assert_response :success
  end

  test "should not get index as student" do
    sign_in(create(:student))
    get feedbacks_url
    assert_redirected_to root_path
  end


  test "should create feedback" do
    assert_difference('Feedback.count') do
      post feedbacks_url, params: { feedback: { comment: "hello", email: "martin@sharypic.com" } }
    end

    assert_redirected_to root_path
  end

  test "should destroy feedback as god" do
    sign_in(create(:god))

    assert_difference('Feedback.count', -1) do
      delete feedback_url(@feedback)
    end

    assert_redirected_to feedbacks_url
  end

  test "should not destroy feedback as student" do
    sign_in(create(:student))
    assert_no_difference('Feedback.count') do
      delete feedback_url(@feedback)
      assert_redirected_to root_path
    end
  end
end
