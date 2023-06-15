module Services
  class TeamMemberInvitationValidator
    def check_invitation
      return :invited if user_already_invited?
      return :already_in_team if db_user_from_email && db_user_from_email.email.in?(current_user.team_members.pluck(:email))
      return :in_another_team if in_a_team?
      return :ok
    end

    attr_reader :email, :user, :current_user

    private

    def initialize(email:, current_user:)
      @email = email
      @current_user = current_user
    end

    def db_user_from_email
      TeamMemberInvitation.find_by(invitation_email: email)
    end

    def user_already_invited?
      current_user.team_member_invitations
                  .where(invitation_email: email)
                  .count
                  .positive?
    end

    def fetch_user
      User.find_by(email: email)
    end

    def in_a_team?
      return false unless fetch_user
      
      TeamMember.where(user_id: fetch_user.id).count.positive?
    end
  end
end