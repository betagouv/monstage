# frozen_string_literal: true

require 'test_helper'

module Reporting
  class InternshipOffersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @sector_agri = create(:sector, name: 'Agriculture')
      @sector_wood = create(:sector, name: 'Filière bois')
      @internship_offer_agri_1 = create(:internship_offer, sector: @sector_agri, max_candidates: 1, max_occurence: 2)
      @internship_offer_agri_2 = create(:internship_offer, sector: @sector_agri, max_candidates: 1, max_occurence: 2)
      @internship_offer_wood = create(:internship_offer, sector: @sector_wood, max_candidates: 10, max_occurence: 2)
      create(:internship_application, :submitted, internship_offer: @internship_offer_agri_1)
      create(:internship_application, :submitted, internship_offer: @internship_offer_agri_1)
      create(:internship_application, :submitted, internship_offer: @internship_offer_agri_2)
    end

    test "GET #index" do
      get reporting_internship_offers_path
      assert_response :success
    end

    test "GET #index forward all safe params to download link" do
      params = {
        is_public: 'true',
        department: 'Ain',
        academy: 'Académie de Paris',
        group: 'MINISTERE DE L\'ACTION ET DES COMPTES PUBLICS'
      }

      get reporting_internship_offers_path(params)
      assert_response :success
      assert_select "a[href=?]", download_reporting_internship_offers_path(params)
    end


    test "GET #download" do
      get download_reporting_internship_offers_path
      assert_response :success
    end
  end
end
