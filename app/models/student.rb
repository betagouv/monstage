class Student < User
  belongs_to :school, optional: true
  delegate :coordinates, to: :school, allow_nil: true

  def targeted_internship_offers
    return InternshipOffer.all unless coordinates
    InternshipOffer.nearby(latitude: coordinates.latitude,
                           longitude: coordinates.longitude)
  end
end
