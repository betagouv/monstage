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
    has_many :team_members,
             foreign_key: :inviter_id

    def internship_offers
      return super unless team.team_size.positive?
      
      InternshipOffer.where(employer: team.team_members.pluck(:member_id))
    end
    
    def internship_agreements
      return super unless team.team_size.positive?

      internship_applications = InternshipApplication.where(internship_offer: internship_offers)
      InternshipAgreement.where(internship_application: internship_applications)
    end


    def pending_invitation_to_a_team
      TeamMember.with_pending_invitations.find_by(invitation_email: email)
    end

    def pending_invitations_to_my_team
      TeamMember.with_pending_invitations.where(inviter_id: team_id)
    end

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

    def team
      Team.new(self)
    end

    def team_id
      team.team_owner_id || id
    end

    def refused_invitations
       TeamMember.refused_invitation.where(inviter_id: team_id)
    end

    def satisfaction_survey_id
      ENV['TALLY_EMPLOYER_SURVEY_ID']
    end
  end
end
