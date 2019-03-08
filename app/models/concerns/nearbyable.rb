module Nearbyable
  extend ActiveSupport::Concern

  included do
    validate :coordinates_are_valid?
    attr_reader :autocomplete

    scope :compute_distance_in_select, -> (latitude:, longitude:, as_name:) {
      select(%{
            ROUND(ST_Distance(
              %s.coordinates,
              ST_GeographyFromText('SRID=4326;POINT(%f %f)')
            )) AS %s
          } % [table_name, longitude, latitude, as_name])
    }

    scope :nearby, -> (latitude:, longitude:, within_radius_in_meter: 60_000) {
      query = %{
        ST_DWithin(
          %s.coordinates,
          ST_GeographyFromText('SRID=4326;POINT(%f %f)'),
          %d
        )
      } % [table_name, longitude, latitude, within_radius_in_meter]
      where(query)
    }

    def coordinates=(coordinates)
      super(geo_point_factory(latitude: coordinates[:latitude],
                              longitude: coordinates[:longitude]))
    end

    def coordinates_are_valid?
      return true if [coordinates&.lat, coordinates&.lon].map(&:to_f).none?(&:zero?)
      errors.add(:coordinates, 'Veuillez renseigner une adresse')
    end
  end
end
