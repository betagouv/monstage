require 'test_helper'

module InternshipOffers
  class CreateTest < ActionDispatch::IntegrationTest
    include SessionManagerTestHelper

    test 'POST #create as visitor redirects to internship_offers' do
      post internship_offers_path(params: {})
      assert_redirected_to internship_offers_path
    end

    test 'POST #create as employer creates the post' do
      internship_offer = FactoryBot.create(:internship_offer)

      sign_in(as: MockUser::Employer) do
        assert_difference('InternshipOffer.count', 1) do
          params = internship_offer.attributes
                    .merge(week_ids: [weeks(:week_2019_1).id],
                           "coordinates" => {latitude: 1, longitude: 1})
          post(internship_offers_path, params: { internship_offer: params })
        end
        assert_redirected_to internship_offer_path(InternshipOffer.last)
      end
    end

    test 'POST #create as employer with missing params' do
      sign_in(as: MockUser::Employer) do
        post(internship_offers_path, params: { internship_offer: {} })
        assert_response :bad_request
      end
    end

    test 'POST #create as employer with invalid data' do
      sign_in(as: MockUser::Employer) do
        post(internship_offers_path, params: { internship_offer: {title: "hello"} })
        assert_response :bad_request
      end
    end
  end
end
