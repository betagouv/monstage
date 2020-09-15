# frozen_string_literal: true

require 'test_helper'

module InternshipOffers
  class NewTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #new as employer show valid form' do
      sign_in(create(:employer))
      travel_to(Date.new(2019, 3, 1)) do
        organisation = create(:organisation)
        internship_offer_info = create(:internship_offer_info)
        get new_dashboard_internship_offer_path(organisation_id: organisation.id, 
                                                internship_offer_info_id: internship_offer_info.id)

        assert_response :success
      end
    end

    test 'GET #new as employer show default values' do
      employer = create(:employer)
      sign_in(employer)
      organisation = create(:organisation)
      internship_offer_info = create(:internship_offer_info)
      get new_dashboard_internship_offer_path(organisation_id: organisation.id, 
                                              internship_offer_info_id: internship_offer_info.id)

      assert_select "#internship_offer_tutor_name[value=\"#{employer.name}\"]"
      assert_select "#internship_offer_tutor_email[value=\"#{employer.email}\"]"
      assert_select 'a.btn-back[href=?]', edit_dashboard_internship_offer_info_path(internship_offer_info.id, organisation_id: organisation.id)
    end

    test 'GET #new as visitor redirects to internship_offers' do
      organisation = create(:organisation)
      internship_offer_info = create(:internship_offer_info)
      get new_dashboard_internship_offer_path(organisation_id: organisation.id, 
                                              internship_offer_info_id: internship_offer_info.id)
      assert_redirected_to user_session_path
    end

    test 'GET #new as Employer with duplicate_id with old offer' do
      internship_offer = create(:weekly_internship_offer, tutor_name: 'Jean', tutor_email: 'jean@mail.com', tutor_phone: '0102030405')
      organisation = create(:organisation)
      internship_offer_info = create(:internship_offer_info)
      sign_in(internship_offer.employer)
      get new_dashboard_internship_offer_path(duplicate_id: internship_offer.id,
                                              organisation_id: organisation.id, 
                                              internship_offer_info_id: internship_offer_info.id)
      assert_response :success
      assert_select 'input[name="internship_offers_weekly_framed[tutor_name]"][value="Jean"]'
      assert_select 'input[name="internship_offers_weekly_framed[tutor_email]"][value="jean@mail.com"]'
      assert_select 'input[name="internship_offers_weekly_framed[tutor_phone]"][value="0102030405"]'
    end
  end
end
