class AddFieldsToTeamMember < ActiveRecord::Migration[7.0]
  def change
    add_column :team_members, :invitation_email, :string, limit: 150, null: false
    add_column :team_members, :invitation_refused_at, :datetime, null: true
  end
end
