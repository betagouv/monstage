# frozen_string_literal: true

module Nearbyable
  DEFAULT_NEARBY_RADIUS_IN_METER = 10_000
  extend ActiveSupport::Concern

  included do
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

    # since relative_distance is not known as a column,
    # this scope is to be used as the very last in the query
    scope :nearby_and_ordered, lambda { |latitude:, longitude:, radius:|
      nearby(latitude: latitude, longitude: longitude, radius: radius)
        .with_distance_from(latitude: latitude, longitude: longitude)
        .unscope(:order)
        .order(relative_distance: :asc)
    }

    scope :with_distance_from, lambda { |latitude:, longitude:|
      query = format(%{
        ST_Distance(
          %s.coordinates,
          ST_GeographyFromText('SRID=4326;POINT(%f %f)')
        ) as relative_distance
      }, table_name, longitude, latitude)

      select(query)
        .select("#{table_name}.*")
    }

    def distance_from(latitude, longitude)
      query = format(%{
        SELECT ST_Distance(
          ST_GeographyFromText('SRID=4326;POINT(%f %f)'),
          coordinates
        ) AS distance
        FROM %s
        WHERE id = %d
      }, longitude, latitude, self.class.table_name, id)

      result = ActiveRecord::Base.connection.execute(query).first
      result['distance'].to_f if result.present?
    end

    def coordinates=(coordinates)
      case coordinates
      when Hash
        if coordinates[:latitude]
          super(geo_point_factory(latitude: coordinates[:latitude],longitude: coordinates[:longitude]))
        else
          super(geo_point_factory(latitude: coordinates['latitude'],longitude: coordinates['longitude']))
        end
      when RGeo::Geographic::SphericalPointImpl
        super(coordinates)
      else
        super
      end
    end

    # def osm_url
    #   return "http://www.openstreetmap.org/" unless coordinates_are_valid?

    #   "http://www.openstreetmap.org/?mlat=#{coordinates.lat}&mlon=#{coordinates.lon}&zoom=12"
    # end

    def formatted_autocomplete_address
      [
        street,
        zipcode,
        city.try(&:capitalize)
      ].compact.uniq.join(' ')
    end

    validate :coordinates_are_valid?
    def coordinates_are_valid?
      return true if [coordinates&.lat, coordinates&.lon].map(&:to_f).none?(&:zero?)

      errors.add(:coordinates, :blank)
    end

  end
end
