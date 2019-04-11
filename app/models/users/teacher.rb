module Users
  class Teacher < User
    belongs_to :class_room, optional: true
    include ManagedUser
    include TargetableInternshipOffersForSchool

    def after_sign_in_path
      return url_helpers.account_path if [school, class_room].any?(&:blank?)
      super
    end

    def custom_dashboard_path
      url_helpers.dashboard_school_class_room_path(school, class_room)
    rescue
      url_helpers.account_path
    end
  end
end
