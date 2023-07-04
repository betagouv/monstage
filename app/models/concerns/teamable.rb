# frozen_string_literal: true

module Teamable
  extend ActiveSupport::Concern

  included do
    has_many :team_member_invitations,
             foreign_key: :inviter_id
    
    def internship_offers
      return super unless team.team_size.positive?
      
      InternshipOffer.where(employer: team_members_ids)
    end
    
    def internship_agreements
      return super unless team.team_size.positive?

      internship_applications = InternshipApplication.where(internship_offer: internship_offers)
      InternshipAgreement.where(internship_application: internship_applications)
    end

    def team
      Team.new(self)
    end

    def team_id
      team.team_owner_id || id
    end

    def team_members_ids
      members = team.team_members.pluck(:member_id)
      members.empty? ? [id] : members
    end

    def pending_invitation_to_a_team
      TeamMemberInvitation.with_pending_invitations.find_by(invitation_email: email)
    end

    def pending_invitations_to_my_team
      TeamMemberInvitation.with_pending_invitations.where(inviter_id: team_id)
    end

    def refused_invitations
      TeamMemberInvitation.refused_invitation.where(inviter_id: team_id)
    end
  end
end
