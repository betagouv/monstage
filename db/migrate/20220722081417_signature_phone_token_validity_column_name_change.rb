class SignaturePhoneTokenValidityColumnNameChange < ActiveRecord::Migration[7.0]
  def up
    rename_column :users, :signature_phone_token_validity, :signature_phone_token_expires_at
  end

  def down
    rename_column :users, :signature_phone_token_expires_at, :signature_phone_token_validity
  end
end
