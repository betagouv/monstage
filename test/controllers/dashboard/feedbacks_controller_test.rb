# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class FeedbacksControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    setup do
      @feedback = create(:feedback)
    end

    test 'should create feedback' do
      assert_difference('Feedback.count') do
        post dashboard_feedbacks_url, params: { feedback: { comment: 'hello', email: 'martin@sharypic.com' } }
      end

      assert_redirected_to root_path
    end
  end
end
