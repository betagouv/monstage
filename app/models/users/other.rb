module Users
  class Other < User
    include ManagedUser
    include TargetableInternshipOffersForSchool


    def custom_dashboard_path
      return url_helpers.dashboard_school_class_rooms_path(school)
    rescue
      url_helpers.account_path
    end

    def dashboard_name
      "Mon Collège"
    end
  end
end
