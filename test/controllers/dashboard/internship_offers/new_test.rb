# frozen_string_literal: true

require 'test_helper'

module InternshipOffers
  class NewTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #new as Employer with duplicate_id with old offer' do
      internship_offer = create(:weekly_internship_offer, tutor_name: 'Jean', tutor_email: 'jean@mail.com', tutor_phone: '0102030405')
      organisation = create(:organisation)
      internship_offer_info = create(:internship_offer_info)
      sign_in(internship_offer.employer)
      get new_dashboard_internship_offer_path(duplicate_id: internship_offer.id,
                                              organisation_id: organisation.id,
                                              internship_offer_info_id: internship_offer_info.id)
      assert_response :success
      assert_select 'input[name="internship_offer[tutor_name]"][value="Jean"]'
      assert_select 'input[name="internship_offer[tutor_email]"][value="jean@mail.com"]'
      assert_select 'input[name="internship_offer[tutor_phone]"][value="0102030405"]'
    end
  end
end
