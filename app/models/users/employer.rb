# frozen_string_literal: true

module Users
  class Employer < User
    include EmployerAdmin
    include Signatorable


    has_many :internship_offers, as: :employer,
                                 dependent: :destroy

    has_many :kept_internship_offers, -> { merge(InternshipOffer.kept) },
             class_name: 'InternshipOffer', foreign_key: 'employer_id'

    has_many :internship_applications, through: :kept_internship_offers
    has_many :internship_agreements, through: :internship_applications

    has_many :organisations
    has_many :tutors
    has_many :internship_offer_infos
    belongs_to :team_member, optional: true
    has_many :team_member_invitations, dependent: :destroy

    def custom_dashboard_path
      return custom_candidatures_path if internship_applications.submitted.any?
      url_helpers.dashboard_internship_offers_path
    end

    def custom_candidatures_path(parameters = {})
      url_helpers.dashboard_candidatures_path(parameters)
    end

    def custom_agreements_path
      url_helpers.dashboard_internship_agreements_path
    end

    def dashboard_name
      'Mon tableau de bord'
    end

    def account_link_name
      'Mon compte'
    end

    def employer? ; true end

    def anonymize(send_email: true)
      super

      internship_offers.map(&:anonymize)
    end

    def signatory_role
      Signature.signatory_roles[:employer]
    end

    def presenter
      Presenters::Employer.new(self)
    end

    def satisfaction_survey_id
      ENV['TALLY_EMPLOYER_SURVEY_ID']
    end
  end
end
