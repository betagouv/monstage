module Users
  class MainTeacher < User
    delegate :school_manager, to: :school
    belongs_to :school, inverse_of: :main_teachers

    belongs_to :class_room, optional: true

    validates :first_name,
              :last_name,
              presence: true

    include NearbyIntershipOffersQueryable
  end
end
