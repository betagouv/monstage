# frozen_string_literal: true

module Users
  class MinistryStatistician < User
    rails_admin do
      configure :last_sign_in_at, :datetime
      configure :created_at, :datetime

      list do
        fields(*UserAdmin::DEFAULTS_FIELDS)
        field :sign_in_count
        field :last_sign_in_at
        field :created_at
      end
    end

    validate :email_in_list

    has_one :statistician_email_whitelist, foreign_key: :user_id, dependent: :destroy
    validates :statistician_email_whitelist, presence: true
    before_validation :assign_statistician_email_whitelist

    def custom_dashboard_path
      url_helpers.reporting_dashboards_path(
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

    def dashboard_name
      'Statistiques par ministère'
    end

    # def department
    #   Department.lookup_by_zipcode(zipcode: department_zipcode)
    # end

    # def department_zipcode
    #   statistician_email_whitelist.zipcode
    # end

    def destroy
      statistician_email_whitelist.delete
      super
    end

    private

    # on create, make sure to assign existing email whitelist
    def assign_statistician_email_whitelist
      self.statistician_email_whitelist = StatisticianEmailWhitelist.where(email: email).first
    end

    def email_in_list
      errors.add(:email, 'Cette adresse électronique n\'est pas autorisée') unless StatisticianEmailWhitelist.exists?(email: email)
    end
  end
end
