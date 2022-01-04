class CreateInvitations< ActiveRecord::Migration[6.1]
  def up
    create_table :invitations do |t|
      t.datetime   :invitation_sent_at
      t.datetime   :invitation_read_at
      t.datetime   :invitation_accepted_at
      t.string   :email, limit: 70
      t.string   :first_name, limit: 60
      t.string   :last_name, limit: 60
      t.string   :role, limit: 50
      t.references :user

      t.timestamps
    end
  end

  def down
    drop_table :invitations 
  end
end
