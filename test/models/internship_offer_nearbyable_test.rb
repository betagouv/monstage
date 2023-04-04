# frozen_string_literal: true

require 'test_helper'

class InternshipOfferNearbyableTest < ActiveSupport::TestCase
  test '.distance_from' do
    coordinates_bordeaux = Coordinates.bordeaux
    create(:internship_offer, coordinates: Coordinates.paris)
    internship_offers = InternshipOffer.with_distance_from(latitude: coordinates_bordeaux[:latitude],
                                                           longitude: coordinates_bordeaux[:longitude])
                                       .all
    assert_equal 499_841.82156578, internship_offers.first.relative_distance
  end
end
