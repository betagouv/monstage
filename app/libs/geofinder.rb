class Geofinder
  def self.street(latitude, longitude)
    result = Geocoder.search([latitude, longitude]).first
    return if result.blank?

    result.data.key?('error') ? nil : result.street
  end

  def self.zipcode(latitude, longitude)
    result = Geocoder.search([latitude, longitude]).first
    return if result.blank?

    result.data.key?('error') ? nil : result.postal_code
  end

  def self.coordinates(full_address)
    result = Geocoder.search(full_address).first
    return [] if result.blank?

    result.data.key?('error') ? [] : result.coordinates
  end
end
