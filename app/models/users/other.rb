# frozen_string_literal: true

module Users
  class Other < User
    include ManagedUser
    include TargetableInternshipOffersForSchool

    def custom_dashboard_path
      url_helpers.dashboard_school_class_rooms_path(school)
    rescue ActionController::UrlGenerationError
      url_helpers.account_path
    end

    def dashboard_name
      'Mon Collège'
    end
  end
end
