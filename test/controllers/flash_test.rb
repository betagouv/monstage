# frozen_string_literal: true

require 'test_helper'

class FlashTest < ActionDispatch::IntegrationTest
  test 'flash presence' do
    get new_dashboard_internship_offer_path
    follow_redirect!
    assert_select('#alert-warning', {}, 'missing flash rendering')
  end
end
