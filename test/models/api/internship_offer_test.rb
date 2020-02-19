# frozen_string_literal: true

require 'test_helper'

class ApiInternshipOfferTest < ActiveSupport::TestCase
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
    internship_offer = Api::InternshipOffer.create(@default_params.merge(remote_id: 1,
                                                                         employer: operator))
    internship_offer_bis = Api::InternshipOffer.create(@default_params.merge(remote_id: 1,
                                                                             employer: operator))
    assert internship_offer.valid?
    assert internship_offer_bis.invalid?
  end

  test 'duplicate remote id different employer does invalid instance' do
    assert Api::InternshipOffer.create(@default_params.merge(remote_id: 1,
                                                             employer: create(:user_operator)))
                               .valid?
    assert Api::InternshipOffer.create(@default_params.merge(remote_id: 1,
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
    assert Api::InternshipOffer.new(@default_params).valid?

    @default_params[:zipcode] = '0'

    refute Api::InternshipOffer.new(@default_params).valid?
  end
end
