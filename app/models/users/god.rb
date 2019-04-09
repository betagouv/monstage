module Users
  class God < User
    scope :targeted_internship_offers, -> (user:) { InternshipOffer.kept }

    def after_sign_in_path
      custom_dashboard_path
    end

    def custom_dashboard_path
      return url_helpers.dashboard_schools_path
    end
  end
end
