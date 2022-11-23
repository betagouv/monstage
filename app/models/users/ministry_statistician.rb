# frozen_string_literal: true

module Users
  class MinistryStatistician < User
    rails_admin do
      weight 6

      configure :last_sign_in_at, :datetime
      configure :created_at, :datetime

      list do
        fields(*UserAdmin::DEFAULT_FIELDS)
        field :ministry_name do
          label 'Administration centrale'
          pretty_value { bindings[:object]&.ministries.map(&:name).join(', ') }
        end
        fields(*UserAdmin::ACCOUNT_FIELDS)

        scopes(UserAdmin::DEFAULT_SCOPES)
      end

      edit do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
      end
    end

    before_validation :assign_email_whitelist_and_confirm
    validate :email_in_whitelist

    has_many :internship_offers, foreign_key: 'employer_id'
    has_one :ministry_email_whitelist,
            class_name: 'EmailWhitelists::Ministry',
            foreign_key: :user_id,
            dependent: :destroy

    def custom_dashboard_path
      url_helpers.reporting_dashboards_path(
        school_year: SchoolYear::Current.new.beginning_of_period.year,
        ministries: ministries.ids.join('A')
      )
    end

    def ministry_email_whitelist
      EmailWhitelists::Ministry.find_by(email: email)
    end

    def ministries
      ministry_email_whitelist&.groups
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


    def ministry_statistician? ; true end
    def statistician? ; true end

    def presenter
      Presenters::MinistryStatistician.new(self)
    end

    def assign_email_whitelist_and_confirm
      self.ministry_email_whitelist = EmailWhitelists::Ministry.find_by(email: email)
      self.confirmed_at = Time.now
    end

    private

    def email_in_whitelist
      if ministries&.empty? || ministry_email_whitelist.nil?
        errors.add(
          :email,
          'Votre adresse électronique n\'est pas reconnue, veuillez la ' \
          'transmettre à monstagedetroisieme@anct.gouv.fr afin que nous ' \
          'puissions la valider.')
      end
    end
  end
end
