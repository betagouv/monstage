class Geofinder
  def self.street(latitude, longitude)
    result = Geocoder.search([latitude, longitude]).first
    result.data.key?('error') ? nil : result.street
  end

  def self.coordinates(full_address)
    result = Geocoder.search(full_address).first
    result.data.key?('error') ? [] : result.coordinates
  end
end
