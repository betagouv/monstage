class CreateTeamMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :team_members do |t|
      t.timestamps
    end
    add_reference :team_members, :user, foreign_key: true, null: false
  end
end
