class Geofinder
  def self.get_street(latitude, longitude)
    result = Geocoder.search([latitude, longitude]).first
    result.data.key?('error') ? nil : result.street
  end
end
