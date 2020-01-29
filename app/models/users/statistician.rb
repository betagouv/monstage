module Users
  class Statistician < User
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

    def custom_dashboard_path
      url_helpers.reporting_internship_offers_path(department: department_name)
    end

    def custom_dashboard_paths
      [
        url_helpers.reporting_internship_offers_path,
        url_helpers.reporting_schools_path
      ]
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
        errors.add(:email, 'Cette adresse électronique n\'est pas autorisée')
      end
    end
  end
end
