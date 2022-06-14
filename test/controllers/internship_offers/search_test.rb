# frozen_string_literal: true

require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest
  test 'GET #search render default form' do
    get search_internship_offers_path

    assert_response :success
    assert_select 'label', text: 'Dates de stage'
  end
end
