# frozen_string_literal: true

module Nearbyable
  DEFAULT_NEARBY_RADIUS_IN_METER = 60_000
  extend ActiveSupport::Concern

  included do
    validate :coordinates_are_valid?

    # rails admin fuck
    def autocomplete; end

    def autocomplete=(val); end

    scope :nearby, lambda { |latitude:, longitude:, radius:|
      query = format(%{
        ST_DWithin(
          %s.coordinates,
          ST_GeographyFromText('SRID=4326;POINT(%f %f)'),
          %d
        )
      }, table_name, longitude, latitude, radius)
      where(query)
    }

    def coordinates=(coordinates)
      case coordinates
      when Hash
        super(geo_point_factory(latitude: coordinates[:latitude],
                                longitude: coordinates[:longitude]))
      when RGeo::Geographic::SphericalPointImpl
        super(coordinates)
      else
        super
      end
    end

    def coordinates_are_valid?
      if [coordinates&.lat, coordinates&.lon].map(&:to_f).none?(&:zero?)
        return true
      end

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
