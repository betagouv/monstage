# frozen_string_literal: true

require 'test_helper'

module Api
  class InternshipOfferTest < ActionDispatch::IntegrationTest
    def write_response_as(report_as:)
      yield
      File.write(Rails.root.join('doc', "#{report_as}.json"), response.body)
    end
    test 'POST #create as visitor redirects to internship_offers' do
      post api_internship_offers_path(params: {})
      assert_response :unauthorized
    end

    test 'POST #create as operator fails with invalid payload respond with :unprocessable_entity' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      write_response_as(report_as: :unprocessable_entity) do
        post api_internship_offers_path(
            params: {
              token: "Bearer #{operator.api_token}",
            }
        )
      end
      assert_response :unprocessable_entity
    end

    test 'POST #create as operator fails with invalid data respond with :bad_request' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      write_response_as(report_as: :bad_request) do
      post api_internship_offers_path(
          params: {
            token: "Bearer #{operator.api_token}",
            internship_offer: {title: ''}
          }
      )
      end
      assert_response :bad_request
    end

    test 'POST #create as operator works to internship_offers' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      week_instances = [weeks(:week_2019_1), weeks(:week_2019_2)]
      sector = create(:sector, uuid: SecureRandom.uuid)

      title = "title"
      description = "description"
      employer_name = "employer_name"
      employer_description = "employer_description"
      employer_website = "http://google.fr"
      coordinates = {latitude: 1, longitude: 1}
      street = "Avenue de l'opéra"
      zipcode = "75002"
      city = "Paris"
      sector_uuid = sector.uuid
      week_params = [
        "#{week_instances.first.year}W#{week_instances.first.number}",
        "#{week_instances.last.year}W#{week_instances.last.number}",
      ]
      remote_id = "test"
      permalink = "https://www.google.fr"
      assert_difference('InternshipOffer.count', 1) do
        write_response_as(report_as: :created) do
          post api_internship_offers_path(
            params: {
              token: "Bearer #{operator.api_token}",
              internship_offer: {
                title: title,
                description: description,
                employer_name: employer_name,
                employer_description: employer_description,
                employer_website: employer_website,
                'coordinates' => coordinates,
                street: street,
                zipcode: zipcode,
                city: city,
                sector_uuid: sector_uuid,
                weeks: week_params,
                remote_id: remote_id,
                permalink: permalink,
              }
            }
          )
        end
        assert_response :created
      end

      internship_offer = InternshipOffer.first
      assert_equal title, internship_offer.title
      assert_equal description, internship_offer.description
      assert_equal employer_name, internship_offer.employer_name
      assert_equal employer_description, internship_offer.employer_description
      assert_equal employer_website, internship_offer.employer_website
      assert_equal coordinates, { latitude: internship_offer.coordinates.latitude,
                                  longitude: internship_offer.coordinates.longitude }
      assert_equal street, internship_offer.street
      assert_equal zipcode, internship_offer.zipcode
      assert_equal city, internship_offer.city

      assert_equal sector, internship_offer.sector
      assert_equal week_instances, internship_offer.weeks
      assert_equal remote_id, internship_offer.remote_id
      assert_equal permalink, internship_offer.permalink
    end
  end
end
