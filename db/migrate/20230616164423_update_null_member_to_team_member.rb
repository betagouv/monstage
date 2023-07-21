class UpdateNullMemberToTeamMember < ActiveRecord::Migration[7.0]
  def change
    change_column_null :team_members, :member_id, true
  end
end
