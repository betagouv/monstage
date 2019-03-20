module Users
  class MainTeacher < User
    belongs_to :school
    belongs_to :class_room, optional: true
    validates :first_name,
              :last_name,
              presence: true

    include NearbyIntershipOffersQueryable
  end
end
