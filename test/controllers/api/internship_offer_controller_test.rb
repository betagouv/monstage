# frozen_string_literal: true

require 'test_helper'

module Api
  class InternshipOfferTest < ActionDispatch::IntegrationTest
    test 'POST #create as visitor redirects to internship_offers' do
      post api_internship_offers_path(params: {})
      assert_response :unauthorized
    end

    test 'POST #create as operator fails gracefully with bad request' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      post api_internship_offers_path(
          params: {
            token: "Bearer #{operator.api_token}",
          }
      )
      assert_response :bad_request
    end

    test 'POST #create as operator works to internship_offers' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      weeks = [weeks(:week_2019_1)]
      sector = create(:sector, uuid: SecureRandom.uuid)

      title = "title"
      description = "description"
      employer_name = "employer_name"
      employer_description = "employer_description"
      employer_website = "http://google.fr"
      coordinates = {latitude: 48.8566, longitude: 2.3522}
      street = "Avenue de l'opéra"
      zipcode = "75002"
      city = "Paris"
      sector_uuid = sector.uuid
      weeks = []
      remote_id = ""
      permalink = ""
      assert_difference('InternshipOffer.count', 1) do
        post api_internship_offers_path(
          params: {
            token: "Bearer #{operator.api_token}",
            internship_offer: {
              title: title,
              description: description,
              employer_name: employer_name,
              employer_description: employer_description,
              employer_website: employer_website,
              coordinates: coordinates,
              street: street,
              zipcode: zipcode,
              city: city,
              sector_uuid: sector_uuid,
              weeks: weeks,
              remote_id: remote_id,
              permalink: permalink,
            }
          }
        )
        assert_response :created
      end

      internship_offer = InternshipOffer.first
      assert_equal title, internship_offer.title
      assert_equal description, internship_offer.description
      assert_equal employer_name, internship_offer.employer_name
      assert_equal employer_description, internship_offer.employer_description
      assert_equal employer_website, internship_offer.employer_website
      assert_equal coordinates, internship_offer.coordinates
      assert_equal street, internship_offer.street
      assert_equal zipcode, internship_offer.zipcode
      assert_equal city, internship_offer.city

      assert_equal sector, internship_offer.sector
      assert_equal weeks, internship_offer.weeks
      assert_equal remote_id, internship_offer.remote_id
      assert_equal permalink, internship_offer.permalink
    end
  end
end
