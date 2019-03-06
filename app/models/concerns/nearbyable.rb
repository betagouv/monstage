module Nearbyable
  extend ActiveSupport::Concern

  included do
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
  end
end
