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

    test 'GET #new as Employer with duplicate_id' do
      operator = create(:user_operator)
      internship_offer = create(:weekly_internship_offer, employer: operator,
                                                          is_public: true,
                                                          max_candidates: 2)
      organisation = create(:organisation)
      internship_offer_info = create(:internship_offer_info)                                                          
      sign_in(internship_offer.employer)
      get new_dashboard_internship_offer_path(duplicate_id: internship_offer.id,
                                              organisation_id: organisation.id, 
                                              internship_offer_info_id: internship_offer_info.id)
      assert_select "input[value=\"#{internship_offer.title}\"]", count: 1
      assert_select '#internship_offer_is_public_true[checked]',
                    count: 1 # "ensure user select kind of group"
      assert_select '#internship_offer_is_public_false[checked]',
                    count: 0 # "ensure user select kind of group"
      assert_select '.form-group-select-group.d-none', count: 0
      assert_select '.form-group-select-group', count: 1

      assert_select '#internship_type_true[checked]', count: 0
      assert_select '#internship_type_false[checked]', count: 1
      assert_select '.form-group-select-max-candidates.d-none', count: 0
      assert_select '.form-group-select-max-candidates', count: 1
    end

    test 'GET #new as Employer with duplicate_id with old offer' do
      internship_offer = create(:weekly_internship_offer)
      internship_offer.update(description_rich_text: nil, employer_description_rich_text: nil)
      internship_offer.update_column(:description, 'woot')
      internship_offer.update_column(:employer_description, 'woot woot')
      organisation = create(:organisation)
      internship_offer_info = create(:internship_offer_info)
      sign_in(internship_offer.employer)
      get new_dashboard_internship_offer_path(duplicate_id: internship_offer.id,
                                              organisation_id: organisation.id, 
                                              internship_offer_info_id: internship_offer_info.id)
      assert_response :success
      assert_select 'input[name="internship_offer[description_rich_text]"][value="woot"]'
      assert_select 'input[name="internship_offer[employer_description_rich_text]"][value="woot woot"]'
    end
  end
end
