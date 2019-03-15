class Student < User
  belongs_to :school, optional: true
  belongs_to :class_room, optional: true

  include NearbyIntershipOffersQueryable

  def to_s
    "#{super}, in school: #{school&.zipcode}"
  end
end
