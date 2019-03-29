module Users
  class MainTeacher < User
    belongs_to :class_room, optional: true

    include NearbyInternshipOffersQueryable
    include ManagedUser
  end
end
