# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class NewTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #new as Employer with duplicate_id' do
      operator = create(:user_operator)
      internship_offer = create(:weekly_internship_offer, employer: operator,
                                                          is_public: true,
                                                          max_candidates: 2)
      sign_in(internship_offer.employer)
      get new_dashboard_internship_offer_path(duplicate_id: internship_offer.id)
      assert_select 'h1', "Renouveller l'offre pour l'année courante"
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
      sign_in(internship_offer.employer)
      get new_dashboard_internship_offer_path(duplicate_id: internship_offer.id)
      assert_response :success
      assert_select 'input[name="internship_offer[description_rich_text]"][value="woot"]'
      assert_select 'input[name="internship_offer[employer_description_rich_text]"][value="woot woot"]'
    end
  end
end
