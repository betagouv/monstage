class CreateTeamMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :team_members do |t|
      t.timestamps
    end
    add_reference :team_members, :inviter, foreign_key: {to_table: :users}, null: false
    add_reference :team_members, :member, foreign_key: {to_table: :users}, null: false
  end
end
