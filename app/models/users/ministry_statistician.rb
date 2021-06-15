# frozen_string_literal: true

module Users
  class MinistryStatistician < User
    rails_admin do
      configure :last_sign_in_at, :datetime
      configure :created_at, :datetime

      list do
        field :ministry_name do
          label 'Administration centrale'
        end
        fields(*UserAdmin::DEFAULTS_FIELDS)
        field :sign_in_count
        field :last_sign_in_at
        field :created_at
      end
    end

    validate :email_in_list

    belongs_to :ministry,
               class_name: 'Group',
               optional: true
    validates_associated :ministry, if: :exists_and_is_public?

    has_one :ministry_email_whitelist,
            class_name: 'EmailWhitelists::Ministry',
            foreign_key: :user_id,
            dependent: :destroy
    validates :ministry_email_whitelist, presence: true

    before_validation :assign_ministry_email_whitelist

    def exists_and_is_public?
      return true if ministry_id.nil?

      ministry.is_public
    end

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
      'Statistiques nationales'
    end

    def destroy
      ministry_email_whitelist.delete
      super
    end

    private

    # on create, make sure to assign existing email whitelist
    def assign_ministry_email_whitelist
      self.ministry_email_whitelist = EmailWhitelists::Ministry.find_by(email: email)
    end

    def email_in_list
      unless EmailWhitelists::Ministry.exists?(email: email)
        errors.add(:email, 'Cette adresse électronique n\'est pas autorisée')
      end
    end
  end
end
