module Services
  class TeamMemberInvitationValidator
    def check_invitation
      return :invited if user_already_invited?
      return :already_in_team if already_in_team?
      return :in_another_team if already_in_another_team?
      return :ok
    end

    attr_reader :email, :current_user

    private

    def initialize(email:, current_user:)
      @email = email
      @current_user = current_user
    end

    def user_already_invited?
      return true if current_user.email == email # self invitation

      TeamMemberInvitation.with_pending_invitations
                .where(invitation_email: email)
                .where(inviter_id: current_user.team_id)
                .exists?
    end

    def already_in_team?
      team = current_user.team
      return false unless team&.team_size&.positive?

      team_members_email = team.team_members.pluck(:invitation_email)
      email.in?(team_members_email)
    end

    def fetch_user
      User.find_by(email: email)
    end

    def already_in_another_team?
      return false unless fetch_user

      TeamMemberInvitation.where(member_id: fetch_user.id)
                .where.not(inviter_id: current_user.team_id)
                .exists?
    end
  end
end