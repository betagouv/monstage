class SerializableInternshipOffer < JSONAPI::Serializable::Resource
  type 'internship_offers'

  attributes :title,
             :description,
             :employer_name,
             :employer_description,
             :employer_website,
             :street,
             :zipcode,
             :city,
             :weeks,
             :remote_id,
             :permalink

  attribute :coordinates do
    {
      latitude: @object.coordinates.latitude,
      longitude: @object.coordinates.longitude
    }
  end
end
