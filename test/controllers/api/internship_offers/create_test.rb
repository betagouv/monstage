# frozen_string_literal: true

require 'test_helper'

module Api
  class CreateTest < ActionDispatch::IntegrationTest
    include ::ApiTestHelpers

    test 'POST #create without token renders :authorized payload' do
      post api_internship_offers_path(params: {})
      write_response_as(report_as: :create_unauthorized) do
        assert_response :unauthorized
        assert_equal "UNAUTHORIZED", json_response["code"]
        assert_equal "wrong api token", json_response["error"]
      end
    end

    test 'POST #create as operator fails with invalid payload respond with :unprocessable_entity' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      write_response_as(report_as: :create_unprocessable_entity) do
        post api_internship_offers_path(
            params: {
              token: "Bearer #{operator.api_token}",
            }
        )
      end
      assert_response :unprocessable_entity
      assert_equal "BAD_PAYLOAD", json_response["code"]
      assert_equal "param is missing or the value is empty: internship_offer", json_response["error"]
    end


    test 'POST #create as operator fails with invalid data respond with :bad_request' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      write_response_as(report_as: :create_bad_request) do
        post api_internship_offers_path(
            params: {
              token: "Bearer #{operator.api_token}",
              internship_offer: {title: ''}
            }
        )
      end
      assert_response :bad_request
      assert_equal "VALIDATION_ERROR", json_response["code"]
      assert_equal ["Missing coordinates"],
                   json_response["error"]["coordinates"],
                   "bad coordinates message"
      assert_equal ["Missing title"],
                   json_response["error"]["title"],
                   "bad title message"
      assert_equal ["Missing employer_name"],
                   json_response["error"]["employer_name"],
                   "bad employer_name message"
      assert_equal ["Missing zipcode"],
                   json_response["error"]["zipcode"],
                   "bad zipcode message"
      assert_equal ["Missing city"],
                   json_response["error"]["city"],
                   "bad city message"
      assert_equal ["Missing remote_id"],
                   json_response["error"]["remote_id"],
                   "bad remote_id message"
      assert_equal ["Missing permalink"],
                   json_response["error"]["permalink"],
                   "bad permalink message"
      assert_equal ["Missing weeks"],
                   json_response["error"]["weeks"],
                   "bad weeks message"
      assert_equal ["Missing description"],
                   json_response["error"]["description"],
                   "bad description message"
      assert_equal ["Missing sector"],
                   json_response["error"]["sector"],
                   "bad sector message"
    end


    test 'POST #create as operator post duplicate remote_id' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      existing_internship_offer = create(:api_internship_offer, employer: operator)
      week_instances = [weeks(:week_2019_1), weeks(:week_2019_2)]
      week_params = [
        "#{week_instances.first.year}W#{week_instances.first.number}",
        "#{week_instances.last.year}W#{week_instances.last.number}",
      ]
      sector = create(:sector, uuid: SecureRandom.uuid)
      internship_offer_params = existing_internship_offer.attributes
                                                         .except(:sector,
                                                                 :weeks,
                                                                 :coordinates)
                                                         .merge(sector_uuid: sector.uuid,
                                                                weeks: week_params,
                                                                coordinates: {latitude: 1, longitude: 1})
      write_response_as(report_as: :create_conflict) do
        post api_internship_offers_path(
            params: {
              token: "Bearer #{operator.api_token}",
              internship_offer: internship_offer_params
            }
        )
      end
      assert_response :conflict
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
        write_response_as(report_as: :create_created) do
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

      internship_offer = Api::InternshipOffer.first
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

      assert_equal JSON.parse(internship_offer.to_json), json_response
    end
  end
end
