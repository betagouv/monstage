# frozen_string_literal: true

module Users
  class Statistician < User
    rails_admin do
      weight 5

      configure :last_sign_in_at, :datetime
      configure :created_at, :datetime

      list do
        scopes(UserAdmin::DEFAULT_SCOPES)

        fields(*UserAdmin::DEFAULT_FIELDS)
        field :department do
          label 'Département'
          pretty_value { bindings[:object]&.department}
        end
        field :department_zipcode do
          label 'Code postal'
          pretty_value { bindings[:object]&.department_zipcode}
        end
        fields(*UserAdmin::ACCOUNT_FIELDS)
      end

      edit do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
      end
    end

    validate :email_in_list

    has_many :internship_offers, foreign_key: 'employer_id'
    has_one :email_whitelist,
            class_name: 'EmailWhitelists::Statistician',
            foreign_key: :user_id,
            dependent: :destroy
    validates :email_whitelist, presence: {message: 'none'}
    before_validation :assign_email_whitelist

    scope :active, -> { where(discarded_at: nil) }

    def custom_dashboard_path
      url_helpers.reporting_dashboards_path(
        department: department,
        school_year: SchoolYear::Current.new.beginning_of_period.year
      )
    end

    def custom_dashboard_paths
      [
        url_helpers.reporting_internship_offers_path,
        url_helpers.reporting_schools_path,
        custom_dashboard_path
      ]
    end

    def statistician?
      true
    end

    def presenter
      Presenters::Statistician.new(self)
    end

    def dashboard_name
      'Statistiques'
    end

    def department
      Department.lookup_by_zipcode(zipcode: department_zipcode)
    end

    def department_zipcode
      email_whitelist&.zipcode
    end

    def destroy
      email_whitelist&.delete
      super
    end

    private

    # on create, make sure to assign existing email whitelist
    def assign_email_whitelist
      self.email_whitelist = EmailWhitelists::Statistician.find_by(email: email)
    end

    def email_in_list
      unless EmailWhitelists::Statistician.exists?(email: email)
        errors.add(
          :email,
          'Votre adresse électronique n\'est pas reconnue, veuillez la ' \
          'transmettre à monstagedetroisieme@anct.gouv.fr afin que nous' \
          ' puissions la valider.'
        )
      end
    end
  end
end
