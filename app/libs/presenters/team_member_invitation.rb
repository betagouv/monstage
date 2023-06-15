module Presenters
  class TeamMemberInvitation

    attr_reader :team_member_invitation

    private

    def initialize(team_member_invitation)
      @team_member_invitation = team_member_invitation
    end
  end
end