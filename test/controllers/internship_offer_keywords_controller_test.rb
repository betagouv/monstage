# frozen_string_literal: true

require 'test_helper'

class InternshipOfferKeywordsControllerTest < ActionDispatch::IntegrationTest
  include ::ApiTestHelpers

  test '#post search with nothing work' do
    post search_internship_offer_keywords_path, params: { keyword: 'bim' }
    assert_response :success
  end

  test '#post search with existing find it' do
    create(:internship_offer, title: 'Horticulteur',
                                     description: 'Des plantes, des fleurs, des légumes',
                                     employer_description: 'De la nature, du bien être')

    dictionnary_api_call_stub
    SyncInternshipOfferKeywordsJob.perform_now
    InternshipOfferKeyword.update_all(searchable: true)

    post(search_internship_offer_keywords_path, params: { keyword: 'Hortic' })

    assert_response :success
    expected_keyword = InternshipOfferKeyword.where(word: 'horticulteur').first
    assert_equal expected_keyword.as_json, json_response[0]
  end

  test '#post search with typo find it' do
    create(:internship_offer, title: 'pâtissier',
                                     description: 'Des plantes, des fleurs, des légumes',
                                     employer_description: 'De la nature, du bien être')

    dictionnary_api_call_stub
    SyncInternshipOfferKeywordsJob.perform_now

    post(search_internship_offer_keywords_path, params: { keyword: 'pattissier' })

    assert_response :success
    expected_keyword = InternshipOfferKeyword.where(word: 'pâtissier').first
    assert_equal expected_keyword.as_json, json_response[0]
  end
end
