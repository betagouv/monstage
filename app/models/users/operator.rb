module Users
  class Operator < User
    belongs_to :operator, foreign_key: :operator_id,
                          class_name: '::Operator'

    scope :targeted_internship_offers, -> (user:) {
      user.internship_offers
    }

    def custom_dashboard_path
      return url_helpers.dashboard_internship_offers_path
    end

    def custom_dashboard_path
      return url_helpers.dashboard_school_class_rooms_path(school)
    rescue
      url_helpers.account_path
    end
  end
end
