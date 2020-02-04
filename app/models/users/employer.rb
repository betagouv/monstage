# frozen_string_literal: true

module Users
  class Employer < User
    include UserAdmin

    has_many :internship_offers, as: :employer,
                                 dependent: :destroy

    def custom_dashboard_path
      url_helpers.dashboard_internship_offers_path
    end

    def dashboard_name
      'Mes offres'
    end

    def account_link_name
      'Mon compte'
    end

    def anonymize
      super

      internship_offers.map(&:anonymize)
    end
  end
end
