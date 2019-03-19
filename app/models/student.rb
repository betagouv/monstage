class Student < User
  belongs_to :school, optional: true
  belongs_to :class_room, optional: true

  include NearbyIntershipOffersQueryable

  has_many :internship_applications

  def to_s
    "#{super}, in school: #{school&.zipcode}"
  end
end
