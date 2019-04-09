module Users
  class MainTeacher < User
    belongs_to :class_room, optional: true
    has_many :students, through: :class_room

    include ManagedUser
    include TargetableInternshipOffersForSchool


    def after_sign_in_path
      return Rails.application.routes.url_helpers.account_path if [school, class_room].any?(&:blank?)
      custom_dashboard_path
    end

    def custom_dashboard_path
      Rails.application.routes.url_helpers.dashboard_school_class_room_path(school, class_room)
    end
  end
end
