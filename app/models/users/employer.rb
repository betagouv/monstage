# frozen_string_literal: true

module Users
  class Employer < User
    has_many :internship_offers, as: :employer,
                                 dependent: :destroy

    scope :targeted_internship_offers, lambda { |user:, coordinates:|
      user.internship_offers
    }

    def custom_dashboard_path
      url_helpers.dashboard_internship_offers_path
    end

    def dashboard_name
      'Mes stages'
    end
  end
end
