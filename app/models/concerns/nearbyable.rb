# frozen_string_literal: true

module Nearbyable
  extend ActiveSupport::Concern

  included do
    validate :coordinates_are_valid?
    attr_reader :autocomplete

    scope :nearby, lambda { |latitude:, longitude:, within_radius_in_meter: 60_000|
      query = format(%{
        ST_DWithin(
          %s.coordinates,
          ST_GeographyFromText('SRID=4326;POINT(%f %f)'),
          %d
        )
      }, table_name, longitude, latitude, within_radius_in_meter)
      where(query)
    }

    def coordinates=(coordinates)
      case coordinates
      when Hash then
        super(geo_point_factory(latitude: coordinates[:latitude],
                                longitude: coordinates[:longitude]))
      when RGeo::Geographic::SphericalPointImpl then
        super(coordinates)
      else
        super
      end
    end

    def coordinates_are_valid?
      return true if [coordinates&.lat, coordinates&.lon].map(&:to_f).none?(&:zero?)

      errors.add(:coordinates, :blank)
    end

    def osm_url
      "http://www.openstreetmap.org/?mlat=#{coordinates.lat}&mlon=#{coordinates.lon}&zoom=12"
    end

    def formatted_autocomplete_address
      [
        street,
        city,
        zipcode
      ].compact.uniq.join(', ')
    end


  end
end
