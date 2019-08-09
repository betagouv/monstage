# frozen_string_literal: true

module Users
  class God < User
    scope :targeted_internship_offers, ->(user:, coordinates:) { InternshipOffer.kept }

    def custom_dashboard_path
      url_helpers.dashboard_schools_path
    end
  end
end
