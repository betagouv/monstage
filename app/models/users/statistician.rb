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
      statisticians.map do |department_number, email_list|
        return department_number if email_list.include?(email)
      end
    end

    private

    def email_in_list
      unless statisticians.values.flatten.include?(email)
        errors.add(:email, 'Cette adresse électronique n\'est pas autorisé')
      end
    end

    def statisticians
      Credentials.enc(:statisticians, prefix_env: false).inject({}) do |accu, (key, value)|
        accu[key.to_s] = value
        accu
      end
    end
  end
end
