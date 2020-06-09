class AddUsersPhoneIndex < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :phone_token, :string
    add_column :users, :phone_token_validity, :datetime
    add_index :users, :phone
  end
end
