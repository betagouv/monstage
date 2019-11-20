# frozen_string_literal: true

RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
  # see: http://www.rubydoc.info/github/rgeo/rgeo/RGeo%2FGeographic.spherical_factory
  POINT_FACTORY = RGeo::Geographic.spherical_factory(srid: 4326,
                                                     has_z_coordinate: false)
  config.default = POINT_FACTORY

  config.register(POINT_FACTORY, geo_type: 'point')
  config.register(POINT_FACTORY, geo_type: 'st_point')
end

def geo_point_factory(latitude:, longitude:)
  type = { geo_type: 'st_point' }
  factory = RGeo::ActiveRecord::SpatialFactoryStore.instance
                                                   .factory(type)
  factory.point(longitude, latitude)
end
