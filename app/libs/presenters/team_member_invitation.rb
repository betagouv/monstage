module Presenters
  class TeamMemberInvitation

    delegate :fetch_invitee_in_db, to: :team_member_invitation

    def full_name
      return "-" if member.nil?
      return "usager disparu" if member.anonymized?
      return "#{member.first_name} #{member.last_name}"
    end

    def email
      return team_member_invitation.invitation_email if member.nil?
      return "email effacé" if member.anonymized?
      return member.email
    end

    def status
      return {label: 'disparu', type: 'warning'}  if fetch_invitee_in_db.present? && fetch_invitee_in_db.discarded?
      return {label: 'refusée', type: 'error'} if team_member_invitation.refused_invitation?
      return {label: 'inscrit', type: 'success'}  if team_member_invitation.accepted_invitation?
      return {label: 'invitation envoyée', type: 'new'} if team_member_invitation.pending_invitation?
      return {label: 'inconnu', type: 'new'}
    end

    attr_reader :team_member_invitation, :current_user, :member

    private

    def fetch_user
      ::User.find_by(id: team_member_invitation.member_id)
    end

    def initialize(team_member_invitation: , current_user:)
      @team_member_invitation = team_member_invitation
      @current_user = current_user
      @member = fetch_user
    end
  end
end