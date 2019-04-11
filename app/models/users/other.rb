module Users
  class Other < User
    include ManagedUser
    include TargetableInternshipOffersForSchool

    def after_sign_in_path
      return url_helpers.account_path if school.blank?
      super
    end

    def custom_dashboard_path
      return url_helpers.dashboard_school_class_rooms_path(school)
    rescue
      url_helpers.account_path
    end
  end
end
