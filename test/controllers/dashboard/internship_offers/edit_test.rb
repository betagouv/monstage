# frozen_string_literal: true

require 'test_helper'

module InternshipOffers
  class EditTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #edit as visitor redirects to user_session_path' do
      get edit_dashboard_internship_offer_path(create(:internship_offer).to_param)
      assert_redirected_to user_session_path
    end

    test 'GET #edit as employer not owning internship_offer redirects to user_session_path' do
      sign_in(create(:employer))
      get edit_dashboard_internship_offer_path(create(:internship_offer).to_param)
      assert_redirected_to root_path
    end

    test 'GET #edit as employer owning internship_offer renders success' do
      employer = create(:employer)
      sign_in(employer)
      internship_offer = create(:internship_offer, employer: employer,
                                                   max_candidates: 2)
      get edit_dashboard_internship_offer_path(internship_offer.to_param)
      assert_select "#internship_offer_max_candidates[value=#{internship_offer.max_candidates}]", count: 1
      Week.selectable_on_school_year.each do |week|
        assert_select "label", text: week.select_text_method
      end
      assert_response :success
    end

    test 'GET #edit with disabled fields if applications exist' do
      employer = create(:employer)
      sign_in(employer)
      internship_offer = create(:internship_offer, employer: employer)
      internship_application = create(:internship_application, :weekly, :submitted, internship_offer: internship_offer)

      travel_to(internship_offer.weeks.first.week_date - 1.week) do
        get edit_dashboard_internship_offer_path(internship_application.internship_offer.to_param)
        assert_response :success
        assert_select 'input#all_year_long[disabled]'

        internship_offer.weeks.each do |week|
          assert_select "label", text: week.select_text_method
        end
        assert_select 'input#internship_offer_max_candidates[disabled]'
      end
    end

    test 'GET #edit with default fields' do
      employer = create(:employer)
      sign_in(employer)
      internship_offer = create(:internship_offer, is_public: true,
                                                   max_candidates: 1,
                                                   tutor_name: 'fourtin mourcade',
                                                   tutor_email: 'fourtin@mour.cade',
                                                   employer: employer)

      get edit_dashboard_internship_offer_path(internship_offer.to_param)
      assert_response :success
      assert_select "#internship_offer_is_public_true[checked]", count: 1 #"ensure user select kind of group"
      assert_select "#internship_offer_is_public_false[checked]", count: 0 #"ensure user select kind of group"
      assert_select ".form-group-select-group.d-none", count: 0
      assert_select ".form-group-select-group", count: 1

      assert_select "#internship_type_true[checked]", count: 1
      assert_select "#internship_type_false[checked]", count: 0

      assert_select '#internship_offer_tutor_name[value="fourtin mourcade"]'
      assert_select '#internship_offer_tutor_email[value="fourtin@mour.cade"]'
      assert_select 'a.btn-back[href=?]', internship_offer_path(internship_offer)
    end
  end
end
