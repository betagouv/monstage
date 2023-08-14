class RemoveTeamMemberInvitationTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :team_member_invitations
  end
end
