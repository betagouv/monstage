# frozen_string_literal: true

require 'test_helper'

module Api
  class CreateTest < ActionDispatch::IntegrationTest
    include ::ApiTestHelpers

    test 'POST #create without token renders :unauthorized payload' do
      post api_internship_offers_path(params: {})
      documents_as(endpoint: :'internship_offers/create', state: :unauthorized) do
        assert_response :unauthorized
        assert_equal 'UNAUTHORIZED', json_code
        assert_equal 'wrong api token', json_error
      end
    end

    test 'POST #create as operator fails with invalid payload respond with :unprocessable_entity' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      documents_as(endpoint: :'internship_offers/create', state: :unprocessable_entity_bad_payload) do
        post api_internship_offers_path(
          params: {
            token: "Bearer #{operator.api_token}"
          }
        )
      end
      assert_response :unprocessable_entity
      assert_equal 'BAD_PAYLOAD', json_code
      assert_equal 'param is missing or the value is empty: internship_offer', json_error
    end

    test 'POST #create as operator fails with invalid data respond with :bad_request' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      documents_as(endpoint: :'internship_offers/create', state: :bad_request) do
        post api_internship_offers_path(
          params: {
            token: "Bearer #{operator.api_token}",
            internship_offer: { title: '', permalink:  'http://staging.lesite.com' }
          }
        )
      end
      assert_response :bad_request
      assert_equal 'VALIDATION_ERROR', json_code
      assert_equal ['Missing coordinates'],
                   json_error['coordinates'],
                   'bad coordinates message'
      assert_equal ['Missing title'],
                   json_error['title'],
                   'bad title message'
      assert_equal ['Missing employer_name'],
                   json_error['employer_name'],
                   'bad employer_name message'
      assert_equal ['Missing zipcode', 'Zipcode is invalid'],
                   json_error['zipcode'],
                   'bad zipcode message'
      assert_equal ['Missing city'],
                   json_error['city'],
                   'bad city message'
      assert_equal ['Missing remote_id'],
                   json_error['remote_id'],
                   'bad remote_id message'
      assert_equal ['Missing sector'],
                   json_error['sector'],
                   'bad sector message'
      assert_equal ['Le lien ne doit pas renvoyer vers un environnement de test.'],
                   json_error['permalink'],
                   'bad permalink message'
    end

    test 'POST #create as operator post duplicate remote_id' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      existing_internship_offer = create(:api_internship_offer, employer: operator)
      week_instances = [weeks(:week_2019_1), weeks(:week_2019_2)]
      week_params = [
        "#{week_instances.first.year}-W#{week_instances.first.number}",
        "#{week_instances.last.year}-W#{week_instances.last.number}"
      ]
      sector = create(:sector, uuid: SecureRandom.uuid)
      internship_offer_params = existing_internship_offer.attributes
                                                         .except(:sector,
                                                                 :weeks,
                                                                 :coordinates)
                                                         .merge(sector_uuid: sector.uuid,
                                                                weeks: week_params,
                                                                coordinates: { latitude: 1, longitude: 1 })
      documents_as(endpoint: :'internship_offers/create', state: :conflict) do
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
      title = 'title'
      description = 'description'
      employer_name = 'employer_name'
      employer_description = 'employer_description'
      employer_website = 'http://google.fr'
      coordinates = { latitude: 1, longitude: 1 }
      street = "Avenue de l'opéra"
      zipcode = '75002'
      city = 'Paris'
      siret = FFaker::CompanyFR.siret
      sector_uuid = sector.uuid
      week_params = [
        "#{week_instances.first.year}-W#{week_instances.first.number}",
        "#{week_instances.last.year}-W#{week_instances.last.number}"
      ]
      remote_id = 'test'
      permalink = 'https://www.google.fr'
      assert_difference('InternshipOffer.count', 1) do
        documents_as(endpoint: :'internship_offers/create', state: :created) do
          post api_internship_offers_path(
            params: {
              token: "Bearer #{operator.api_token}",
              internship_offer: {
                title: title,
                description: description,
                employer_name: employer_name,
                employer_description: employer_description,
                employer_website: employer_website,
                siret: siret,
                'coordinates' => coordinates,
                street: street,
                zipcode: zipcode,
                city: city,
                sector_uuid: sector_uuid,
                weeks: week_params,
                remote_id: remote_id,
                permalink: permalink,
                max_candidates: 2
              }
            }
          )
        end
        assert_response :created
      end

      internship_offer = InternshipOffers::Api.first
      assert_equal title, internship_offer.title
      assert_equal description, internship_offer.description
      assert_equal employer_name, internship_offer.employer_name
      assert_equal employer_description, internship_offer.employer_description
      assert_equal employer_website, internship_offer.employer_website
      assert_equal coordinates, latitude: internship_offer.coordinates.latitude,
                                longitude: internship_offer.coordinates.longitude
      assert_equal street, internship_offer.street
      assert_equal zipcode, internship_offer.zipcode
      assert_equal city, internship_offer.city

      assert_equal sector, internship_offer.sector
      week_instances.to_a.map do |week_instance|
        assert_includes internship_offer.weeks.map(&:id), week_instance.id
      end
      assert_equal remote_id, internship_offer.remote_id
      assert_equal permalink, internship_offer.permalink
      assert_equal 'troisieme_generale', internship_offer.school_track
      assert_equal 2, internship_offer.max_candidates

      assert_equal JSON.parse(internship_offer.to_json), json_response
    end

    test 'POST #create as operator with no weeks params use all selectable week from now until end of school year' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      sector = create(:sector, uuid: SecureRandom.uuid)

      travel_to(Date.new(2019, 3, 1)) do
        assert_difference('InternshipOffer.count', 1) do
          post api_internship_offers_path(
            params: {
              token: "Bearer #{operator.api_token}",
              internship_offer: {
                title: 'title',
                description: 'description',
                employer_name: 'employer_name',
                employer_description: 'employer_description',
                employer_website: 'http://employer_website.com',
                siret: FFaker::CompanyFR.siret,
                coordinates: { latitude: 1, longitude: 1 },
                street: 'street',
                zipcode: '60580',
                city: 'Coye la forêt',
                sector_uuid: sector.uuid,
                remote_id: 'remote_id',
                permalink: 'http://google.fr/permalink'
              }
            }
          )
          assert_response :created
        end

        internship_offer = InternshipOffers::Api.first
        week_ids = internship_offer.weeks.map(&:id)
        Week.selectable_from_now_until_end_of_school_year.each do |week|
          assert week_ids.include?(week.id)
        end
      end
    end

    test 'POST #create as operator with badly formed weeks params raises a not_found error' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      sector = create(:sector, uuid: SecureRandom.uuid)
      faulty_week =  '2020-Wsem9-23'
      faulty_weeks = ['2020-W8', faulty_week]

      travel_to(Date.new(2019, 3, 1)) do
        assert_difference('InternshipOffer.count', 0) do
          documents_as(endpoint: :'internship_offers/create', state: :unprocessable_entity_bad_data) do
            post api_internship_offers_path(
              params: {
                token: "Bearer #{operator.api_token}",
                internship_offer: {
                  title: 'title',
                  description: 'description',
                  weeks: faulty_weeks,
                  employer_name: 'employer_name',
                  employer_description: 'employer_description',
                  employer_website: 'http://employer_website.com',
                  siret: FFaker::CompanyFR.siret,
                  coordinates: { latitude: 1, longitude: 1 },
                  street: 'street',
                  zipcode: '60580',
                  city: 'Coye la forêt',
                  sector_uuid: sector.uuid,
                  remote_id: 'remote_id',
                  permalink: 'http://google.fr/permalink'
                }
              }
            )
          end
          assert_response :unprocessable_entity
          assert_equal 'BAD_ARGUMENT', json_code
          assert_equal "bad week format: #{faulty_week}, expecting ISO 8601 format", json_error
        end
      end
    end

    test 'POST #create as operator with empty street creates the internship offer' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      sector = create(:sector, uuid: SecureRandom.uuid)
      geocoder_response = {
        status: 200,
        body: [{
          "address": {"office": "Ministère de l'Éducation Nationale", "road": "Rue de Grenelle", "suburb": "7th Arrondissement", "city_district": "7th Arrondissement", "city": "Paris", "municipality": "Paris", "county": "Paris", "country": "France", "postcode": "75007", "country_code": "fr"}
        }].to_json
      }
      stub_request(:get, "https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=48.8566383&lon=2.3211761").to_return(geocoder_response)

      travel_to(Date.new(2019, 3, 1)) do
        assert_difference('InternshipOffer.count', 1) do
          documents_as(endpoint: :'internship_offers/create', state: :unprocessable_entity_bad_data) do
            post api_internship_offers_path(
              params: {
                token: "Bearer #{operator.api_token}",
                internship_offer: {
                  title: 'title',
                  description: 'description',
                  employer_name: 'Ministere',
                  employer_description: 'employer_description',
                  employer_website: 'http://employer_website.com',
                  coordinates: { latitude: 48.8566383, longitude: 2.3211761 },
                  street: '',
                  zipcode: '75007',
                  city: 'Paris',
                  sector_uuid: sector.uuid,
                  remote_id: 'remote_id',
                  permalink: 'http://google.fr/permalink'
                }
              }
            )
          end
          assert_response :created
        end
        internship_offer = InternshipOffers::Api.first
        assert_equal 'Rue de Grenelle', internship_offer.street
      end
    end

    test 'POST #create as operator with empty zipcode creates the internship offer' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      sector = create(:sector, uuid: SecureRandom.uuid)
      geocoder_response = {
        status: 200,
        body: [{
          "address": {"office": "Ministère de l'Éducation Nationale", "road": "Rue de Grenelle", "suburb": "7th Arrondissement", "city_district": "7th Arrondissement", "city": "Paris", "municipality": "Paris", "county": "Paris", "country": "France", "postcode": "75007", "country_code": "fr"}
        }].to_json
      }
      stub_request(:get, "https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=48.8566383&lon=2.3211761").to_return(geocoder_response)

      travel_to(Date.new(2019, 3, 1)) do
        assert_difference('InternshipOffer.count', 1) do
          documents_as(endpoint: :'internship_offers/create', state: :unprocessable_entity_bad_data) do
            post api_internship_offers_path(
              params: {
                token: "Bearer #{operator.api_token}",
                internship_offer: {
                  title: 'title',
                  description: 'description',
                  employer_name: 'Ministere',
                  employer_description: 'employer_description',
                  employer_website: 'http://employer_website.com',
                  coordinates: { latitude: 48.8566383, longitude: 2.3211761 },
                  street: '',
                  zipcode: '',
                  siret: FFaker::CompanyFR.siret,
                  city: 'Paris',
                  sector_uuid: sector.uuid,
                  remote_id: 'remote_id',
                  permalink: 'http://google.fr/permalink'
                }
              }
            )
          end
          assert_response :created
        end
        internship_offer = InternshipOffers::Api.first
        assert_equal 'Rue de Grenelle', internship_offer.street
      end
    end

    test 'POST #create as operator with without street creates the internship offer' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      sector = create(:sector, uuid: SecureRandom.uuid)
      geocoder_response = {
        status: 200,
        body: [{
          "address": {"office": "Ministère de l'Éducation Nationale", "road": "Rue de Grenelle", "suburb": "7th Arrondissement", "city_district": "7th Arrondissement", "city": "Paris", "municipality": "Paris", "county": "Paris", "country": "France", "postcode": "75007", "country_code": "fr"}
        }].to_json
      }
      stub_request(:get, "https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=48.8566383&lon=2.3211761").to_return(geocoder_response)


      travel_to(Date.new(2019, 3, 1)) do
        assert_difference('InternshipOffer.count', 1) do
          documents_as(endpoint: :'internship_offers/create', state: :unprocessable_entity_bad_data) do
            post api_internship_offers_path(
              params: {
                token: "Bearer #{operator.api_token}",
                internship_offer: {
                  title: 'title',
                  description: 'description',
                  employer_name: 'Ministere',
                  employer_description: 'employer_description',
                  employer_website: 'http://employer_website.com',
                  coordinates: { latitude: 48.8566383, longitude: 2.3211761 },
                  zipcode: '75007',
                  city: 'Paris',
                  siret: FFaker::CompanyFR.siret,
                  sector_uuid: sector.uuid,
                  remote_id: 'remote_id',
                  permalink: 'http://google.fr/permalink'
                }
              }
            )
          end
          assert_response :created
        end
        internship_offer = InternshipOffers::Api.first
        assert_equal 'Rue de Grenelle', internship_offer.street
      end
    end

    test 'POST #create as operator with wrong coordinates creates the internship offer with N/A street' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      sector = create(:sector, uuid: SecureRandom.uuid)
      geocoder_response = {
        status: 200,
        body: [{ "error": "wrong address" }].to_json
      }
      stub_request(:get, "https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=148&lon=14").to_return(geocoder_response)


      travel_to(Date.new(2019, 3, 1)) do
        assert_difference('InternshipOffer.count', 1) do
          documents_as(endpoint: :'internship_offers/create', state: :unprocessable_entity_bad_data) do
            post api_internship_offers_path(
              params: {
                token: "Bearer #{operator.api_token}",
                internship_offer: {
                  title: 'title',
                  description: 'description',
                  employer_name: 'Ministere',
                  employer_description: 'employer_description',
                  employer_website: 'http://employer_website.com',
                  siret: FFaker::CompanyFR.siret,
                  coordinates: { latitude: 148, longitude: 14 },
                  zipcode: '75007',
                  city: 'Paris',
                  sector_uuid: sector.uuid,
                  remote_id: 'remote_id',
                  permalink: 'http://google.fr/permalink'
                }
              }
            )
          end
          assert_response :created
        end
        internship_offer = InternshipOffers::Api.first
        assert_equal 'N/A', internship_offer.street
      end
    end
  end
end
