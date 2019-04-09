module Users
  class Employer < User
    has_many :internship_offers, dependent: :destroy

    scope :targeted_internship_offers, -> (user:) {
      user.internship_offers
    }

    def after_sign_in_path
      custom_dashboard_path
    end

    def custom_dashboard_path
      return url_helpers.internship_offers_path
    end
  end
end
