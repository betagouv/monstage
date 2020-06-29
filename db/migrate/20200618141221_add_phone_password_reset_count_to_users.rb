class AddPhonePasswordResetCountToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :phone_password_reset_count, :integer, default: 0
    add_column :users, :last_phone_password_reset, :datetime
  end
end
