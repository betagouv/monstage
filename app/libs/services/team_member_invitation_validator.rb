module Services
  class TeamMemberInvitationValidator
    def check_invitation
      return :invited if user_already_invited?
      return :already_in_team if already_in_team?
      return :in_another_team if already_in_another_team?
      return :self_invitation if self_invitation?
      return :ok
    end

    attr_reader :email, :current_user

    private

    def initialize(email:, current_user:)
      @email = email
      @current_user = current_user
    end

    def user_already_invited?
      TeamMember.with_pending_invitations
                .where(invitation_email: email)
                .where(inviter_id: current_user_team_owner_id)
                .exists?
    end

    def already_in_team?
      current_user.team.alive?
    end

    def current_user_team_owner_id
      current_user.team&.team_owner_id
    end

    def fetch_user
      User.find_by(email: email)
    end

    def already_in_another_team?
      return false unless fetch_user

      TeamMember.where(member_id: fetch_user.id)
                .where.not(inviter_id: current_user_team_owner_id)
                .exists?
    end

    def self_invitation?
      current_user.email == email
    end
  end
end