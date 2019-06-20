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
      'coordinates' => {latitude: 1, longitude: 1},
      street: '7 rue du puits',
      zipcode: '60580',
      city: 'Coye la foret',
      sector: create(:sector),
      weeks: [weeks(:week_2019_1)],
      permalink: "https://google.fr",
    }
  end

  test "duplicate remote id same employer invalid instance" do
    operator = create(:user_operator)
    internship_offer = Api::InternshipOffer.create(@default_params.merge(remote_id: 1,
                                                                         employer: operator))
    internship_offer_bis = Api::InternshipOffer.create(@default_params.merge(remote_id: 1,
                                                                             employer: operator))
    assert internship_offer.valid?
    assert internship_offer_bis.invalid?
  end

  test "duplicate remote id different employer does invalid instance" do
    assert Api::InternshipOffer.create(@default_params.merge(remote_id: 1,
                                                             employer: create(:user_operator)))
                               .valid?
    assert Api::InternshipOffer.create(@default_params.merge(remote_id: 1,
                                                             employer: create(:user_operator)))
                               .valid?
  end

end
