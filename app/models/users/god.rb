# frozen_string_literal: true

module Users
  class God < User
    include UserAdmin

    include InternshipOffersScopes::ByCoordinates

    scope :targeted_internship_offers, ->(user:, coordinates:) {
      query = InternshipOffer.kept
      query = query.merge(internship_offers_nearby(coordinates: coordinates)) if coordinates
      query
    }

    def custom_dashboard_path
      url_helpers.rails_admin_path
    end

    def dashboard_name
      'Admin'
    end
  end
end
