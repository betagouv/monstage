# frozen_string_literal: true

require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest
  test 'GET #search render default form' do
    get search_internship_offers_path

    assert_response :success
    assert_select "label[for=input-search-by-keyword]"
    assert_select "label[for=input-search-by-city]"
    assert_select "label", text:  "Filtrer par filière"
    assert_select ".label", text:  "Quand se déroule le stage ?"
    ClassRoom.school_tracks.map do |(enum)|
      assert_select "select option[value=\"#{enum}\"]"
    end
  end
end
