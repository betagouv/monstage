# frozen_string_literal: true

module Users
  class SchoolManagement < User
    include UserAdmin
    enum role: {
      school_manager: 'school_manager',
      teacher: 'teacher',
      main_teacher: 'main_teacher',
      other: 'other'
    }

    validates :email, format: /\A[^@\s]+@ac-[^@\s]+\z/, if: :school_manager?

    belongs_to :class_room, optional: true
    has_many :students, through: :class_room
    belongs_to :school, optional: true

    def after_sign_in_path
      return url_helpers.account_path if school.blank? || school.weeks.empty?

      super
    end


    def custom_dashboard_path
      url_helpers.dashboard_school_class_rooms_path(school) if school.present?

      url_helpers.account_path
    rescue ActionController::UrlGenerationError
      url_helpers.account_path
    end



    def custom_dashboard_paths
      [
        url_helpers.dashboard_school_class_room_path(school, class_room)
      ]
    rescue ActionController::UrlGenerationError
      []
    end

    def dashboard_name
      'Mon Collège'
    end


  end
end
