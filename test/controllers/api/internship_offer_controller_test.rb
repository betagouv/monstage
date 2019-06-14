# frozen_string_literal: true

require 'test_helper'

module Api
  class InternshipOfferTest < ActionDispatch::IntegrationTest
    test 'POST #create as visitor redirects to internship_offers' do
      post api_internship_offers_path(params: {})
      assert_equal 401, response.status
    end

    test 'POST #create as operator works to internship_offers' do
      flunk "TBD"
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


      assert_equal 200, response.status
    end
  end
end
