class AddGroupToEmailWhitelist < ActiveRecord::Migration[6.1]
  def up
    add_column :email_whitelists, :group_id, :integer, null: true
  end

  def down
    remove_column :email_whitelists, :group_id
  end
end
