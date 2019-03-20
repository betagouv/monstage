module Users
  class MainTeacher < User
    belongs_to :school
    has_one :school_manager, through: :school
    belongs_to :class_room, optional: true

    validates :first_name,
              :last_name,
              presence: true
    validates :school_manager, presence: true,
                               if: :school_id_changed?
    validates :school_manager, presence: true,
                               on: :create

    before_update :notify_school_manager, if: :school_id_changed?
    before_create :notify_school_manager, if: :school_id_changed?

    include NearbyIntershipOffersQueryable

    def notify_school_manager
    end
  end
end
