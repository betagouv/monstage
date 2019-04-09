module Users
  class Other < User
    include ManagedUser
    include TargetableInternshipOffersForSchool

    def after_sign_in_path
      return Rails.application.routes.url_helpers.account_path if school.blank?
      custom_dashboard_path
    end

    def custom_dashboard_path
      return Rails.application.routes.url_helpers.dashboard_school_path(school)
    end
  end
end
