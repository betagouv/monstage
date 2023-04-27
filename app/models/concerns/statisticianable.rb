# frozen_string_literal: true

module Statisticianable
  extend ActiveSupport::Concern

  included do
    has_many :internship_offers, as: :employer,
    dependent: :destroy

    has_many :kept_internship_offers, -> { merge(InternshipOffer.kept) },
    class_name: 'InternshipOffer', foreign_key: 'employer_id'

    has_many :internship_applications, through: :kept_internship_offers
    has_many :internship_agreements, through: :internship_applications
    has_many :organisations
    has_many :tutors
    has_many :internship_offer_infos

    before_update :trigger_agreements_creation
    before_validation :assign_email_whitelist_and_confirm
    # Beware : order matters here !
    validate :email_in_list

    scope :active, -> { where(discarded_at: nil) }

    def custom_dashboard_path
      url_helpers.reporting_dashboards_path(
        department: department,
        school_year: SchoolYear::Current.new.beginning_of_period.year
      )
    end

    def custom_candidatures_path(parameters = {})
      url_helpers.dashboard_candidatures_path(parameters)
    end

    def custom_dashboard_paths
      [
        url_helpers.reporting_internship_offers_path,
        url_helpers.reporting_schools_path,
        custom_dashboard_path
      ]
    end
  
    def statistician? ; true end

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

      show do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
      end

      edit do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
        field :agreement_signatorable do
          label 'Signataire des conventions'
          help 'Si le V est coché en vert, le signataire doit signer TOUTES les conventions'
        end
      end
    end

    def signatory_role
      Signature.signatory_roles[:employer]
    end

  end
end
