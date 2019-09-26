module Users
  class Statistician < User
    include InternshipOffersScopes::ByCoordinates
    include UserAdmin

    rails_admin do
      list do
        field :sign_in_count
        field :last_sign_in_at
        field :confirmed_at
        field :created_at
      end
    end

    validate :email_in_list

    scope :targeted_internship_offers, ->(user:, coordinates:) {
      query = InternshipOffer.kept
      query = query.merge(internship_offers_nearby(coordinates: coordinates)) if coordinates
      query
    }

    def custom_dashboard_path
      url_helpers.reporting_internship_offers_path(department: department_name)
    end

    def department_name
      Department.lookup_by_zipcode(zipcode: department_zipcode)
    end

    def department_zipcode
      EmailWhitelist.where(email: email).first.zipcode
    end

    private

    def email_in_list
      unless EmailWhitelist.exists?(email: email)
        errors.add(:email, 'Cette adresse électronique n\'est pas autorisé')
      end
    end
  end
end
