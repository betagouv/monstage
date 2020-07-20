# frozen_string_literal: true

require 'test_helper'

module InternshipOffers
  class ApiTest < ActiveSupport::TestCase
    setup do
      @default_params = {
        title: 'foo',
        description: 'bar',
        employer_name: 'baz',
        employer_description: 'rab',
        employer_website: 'https://www.google.fr',
        'coordinates' => { latitude: 1, longitude: 1 },
        street: '7 rue du puits',
        remote_id: 1,
        employer: create(:employer),
        zipcode: '60580',
        city: 'Coye la foret',
        sector: create(:sector),
        weeks: [weeks(:week_2019_1)],
        permalink: 'https://google.fr'
      }
    end

    test 'duplicate remote id same employer invalid instance' do
      operator = create(:user_operator)
      internship_offer = InternshipOffers::Api.create(@default_params.merge(remote_id: 1,
                                                                            employer: operator))
      internship_offer_bis = InternshipOffers::Api.create(@default_params.merge(remote_id: 1,
                                                                                employer: operator))
      assert internship_offer.valid?
      assert internship_offer_bis.invalid?
    end

    test 'duplicate remote id different employer does invalid instance' do
      assert InternshipOffers::Api.create(@default_params.merge(remote_id: 1,
                                                                employer: create(:user_operator)))
                                  .valid?
      assert InternshipOffers::Api.create(@default_params.merge(remote_id: 1,
                                                                employer: create(:user_operator)))
                                  .valid?
    end

    test '.as_json' do
      internship_offer = build(:api_internship_offer)
      json = internship_offer.as_json
      assert_equal({ 'latitude' => Coordinates.paris[:latitude],
                     'longitude' => Coordinates.paris[:longitude] },
                   json['formatted_coordinates'])
    end

    test 'zipcode error' do
      assert InternshipOffers::Api.new(@default_params).valid?

      @default_params[:zipcode] = '0'

      refute InternshipOffers::Api.new(@default_params).valid?
    end

    test 'default max_candidates' do
      assert_equal 1, InternshipOffers::Api.new.max_candidates
      assert_equal 1, InternshipOffers::Api.new(max_candidates: '').max_candidates
    end

    test 'is_public does not changes' do
      internship_offer = create(:api_internship_offer, is_public: true)
      internship_offer.title = 'booboop'
      internship_offer.save!
      assert InternshipOffer.pluck(:is_public).all?
    end
  end
end
