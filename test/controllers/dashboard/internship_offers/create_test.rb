require 'test_helper'

module InternshipOffers
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'POST #create as visitor redirects to internship_offers' do
      post dashboard_internship_offers_path(params: {})
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
                         max_candidates: 2,
                         max_internship_week_number: 4,
                         employer_description: "bim bim bim bam bam",
                         employer_id: internship_offer.employer_id,
                         employer_type: "Users::Employer")

        post(dashboard_internship_offers_path, params: { internship_offer: params })
      end
      created_internship_offer = InternshipOffer.last
      assert_equal employer, created_internship_offer.employer
      assert_equal school, created_internship_offer.school
      assert_equal weeks.map(&:id), created_internship_offer.week_ids
      assert_equal 2, created_internship_offer.max_candidates
      assert_equal 4, created_internship_offer.max_internship_week_number
      assert_redirected_to dashboard_internship_offer_path(created_internship_offer)
    end

    test 'POST #create as employer with missing params' do
      sign_in(create(:employer))
      post(dashboard_internship_offers_path, params: { internship_offer: {} })
      assert_response :bad_request
    end

    test 'POST #create as employer with invalid data' do
      sign_in(create(:employer))
      post(dashboard_internship_offers_path, params: { internship_offer: {title: "hello"} })
      assert_response :bad_request
    end

  end
end
