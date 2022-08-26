class AddSignaturePhoneTokenToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :signature_phone_token, :string, limit: 6, after: :phone_token, null: true
    add_column :users, :signature_phone_token_validity, :datetime, after: :signature_phone_token, null: true
  end
  def down
    remove_column :users, :signature_phone_token
    remove_column :users, :signature_phone_token_validity
  end
end
