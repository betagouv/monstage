class RemoveEmailWhitelistTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :email_whitelists  if table_exists?(:email_whitelists)
  end

  def down
  end
end
