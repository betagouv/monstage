module Users
  class Statistician < User
    validate :email_in_list
    include InternshipOffersScopes::ByCoordinates
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
      HASH_MAP_EMAIL.map do |department_number, email_list|
        return department_number if email_list.include?(email)
      end
    end

    private

    HASH_MAP_EMAIL = { '60' =>['fourcade.m@gmail.com'] }

    def email_in_list
      unless HASH_MAP_EMAIL.values.flatten.include?(email)
        errors.add(:email, 'Cette adresse électronique n\'est pas autorisé')
      end
    end
  end
end
