class AddUserIdToEmailWhitelists < ActiveRecord::Migration[6.0]
  def change
    add_reference :email_whitelists, :user, foreign_key: { to_table: :users }
  end
end
