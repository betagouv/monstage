require 'test_helper'

module InternshipOffers
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'POST #create as visitor redirects to internship_offers' do
      post internship_offers_path(params: {})
      assert_redirected_to user_session_path
    end

    test 'POST #create as employer creates the post' do
      school = create(:school)
      employer = create(:employer)
      weeks = [weeks(:week_2019_1)]
      internship_offer = build(:internship_offer, employer: employer)
      sign_in(internship_offer.employer)
      assert_difference('InternshipOffer.count', 1) do
        params = internship_offer
                  .attributes
                  .merge(week_ids: weeks.map(&:id),
                         "coordinates" => { latitude: 1, longitude: 1 },
                         school_id: school.id,
                         employer_description: "bim bim bim bam bam")
        post(internship_offers_path, params: { internship_offer: params })
      end
      created_internship_offer = InternshipOffer.last
      assert_equal employer, created_internship_offer.employer
      assert_equal school, created_internship_offer.school
      assert_equal weeks.map(&:id), created_internship_offer.week_ids
      assert_redirected_to internship_offer_path(created_internship_offer)
    end

    test 'POST #create as employer with missing params' do
      sign_in(create(:employer))
      post(internship_offers_path, params: { internship_offer: {} })
      assert_response :bad_request
    end

    test 'POST #create as employer with invalid data' do
      sign_in(create(:employer))
      post(internship_offers_path, params: { internship_offer: {title: "hello"} })
      assert_response :bad_request
    end

  end
end
