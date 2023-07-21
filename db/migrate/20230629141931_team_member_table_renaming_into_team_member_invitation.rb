class TeamMemberTableRenamingIntoTeamMemberInvitation < ActiveRecord::Migration[7.0]
  def change
    rename_table :team_members, :team_member_invitations
  end
end
