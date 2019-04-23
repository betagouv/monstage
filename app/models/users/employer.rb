module Users
  class Employer < User
    has_many :internship_offers, as: :employer,
                                 dependent: :destroy


    scope :targeted_internship_offers, -> (user:) {
      user.internship_offers
    }

    def custom_dashboard_path
      return url_helpers.dashboard_internship_offers_path
    end
  end
end
