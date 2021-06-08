class AddTypeToEmailWhitelist < ActiveRecord::Migration[6.1]
  def up
    add_column :email_whitelists, :type, :string, null: false, default:'EmailWhitelist::Statistician'
  end

  def down
    remove_column :email_whitelists, :type, :string
  end
end
