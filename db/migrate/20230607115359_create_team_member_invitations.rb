class CreateTeamMemberInvitations < ActiveRecord::Migration[7.0]
  def change
    # Just set an email
    create_table :team_member_invitations do |t|
      t.string :invitation_email, null: false
      t.timestamps
    end
    add_reference :team_member_invitations, :user, foreign_key: true, null: false
  end
end
