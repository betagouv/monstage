# frozen_string_literal: true

module Users
  class Teacher < User
    belongs_to :class_room, optional: true
    include ManagedUser
    include TargetableInternshipOffersForSchool

    def custom_dashboard_path
      url_helpers.dashboard_school_class_room_path(school, class_room)
    rescue StandardError
      url_helpers.account_path
    end

    def custom_dashboard_paths
      [
        url_helpers.dashboard_school_class_room_path(school, class_room)
      ]
    rescue StandardError
      [
      ]
    end

    def dashboard_name
      'Ma classe'
    end
  end
end
