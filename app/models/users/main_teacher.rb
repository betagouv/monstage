module Users
  class MainTeacher < User
    belongs_to :class_room, optional: true
    has_many :students, through: :class_room

    include ManagedUser
    include TargetableInternshipOffersForSchool
  end
end
